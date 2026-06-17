import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/graphql/orders/mutation.dart';
import 'package:plant_aplication/graphql/orders/query.dart';
import 'package:plant_aplication/services/authHelper.dart';
import 'package:plant_aplication/services/authStorage.dart';

class CreateOrderController {
  /// Places a new order against the `placeOrder` mutation.
  ///
  /// [input] is the legacy Flutter input shape. It is translated to
  /// [PlaceOrderInput]. Supported keys on [input]:
  ///   - `shippingAddressId` or `customerAddressId` -> `customerAddressId`
  ///   - `note`
  ///   - `orderItems` (list of `{productId, quantity, unitPrice, totalPrice?,
  ///      unitId?, unit?, weightGrams?, note?}`) -> `items`
  ///   - `payments` (list of `{paymentMethod, currency, amount}`)
  ///     If not supplied but `paymentMethod` is present on [input], a single
  ///     payment entry is synthesised using the order total.
  ///
  /// Unsupported legacy keys (`orderNumber`, `promoCodeId`, `shippingCost`,
  /// `estimatedDelivery`, `shippingMethod`, `paymentStatus`) are dropped.
  static Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> input,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final placeOrderInput = _buildPlaceOrderInput(input);

      final result = await client.mutate(
        MutationOptions(
          document: gql(CreateOrder),
          variables: {'input': placeOrderInput},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }

      final payload = result.data?['placeOrder'];
      if (payload == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }

      // Backwards-compat: expose `data` alongside the new `sale` field.
      final map = Map<String, dynamic>.from(payload as Map);
      if (map['data'] == null && map['sale'] != null) {
        map['data'] = map['sale'];
      }
      return map;
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  /// Fetches the current customer's orders.
  ///
  /// The returned maps preserve the legacy `orderItems` key (a flat copy of
  /// `saleDetails` with the parent sale's `status`, `saleDate`, and
  /// `orderId` merged in) so existing UI code continues to work.
  static Future<List<Map<String, dynamic>>> fetchOrders({
    String? status,
    int? limit,
    int? offset,
  }) async {
    final client = await _createClient();
    final variables = <String, dynamic>{};
    if (status != null) variables['status'] = status;
    if (limit != null) variables['limit'] = limit;
    if (offset != null) variables['offset'] = offset;

    final result = await client.query(
      QueryOptions(
        document: gql(QueryOrder),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      debugPrint('fetchOrders exception: ${result.exception}');
      return [];
    }

    final sales = result.data?['myOrders']?['sales'];
    if (sales == null) return [];

    final list = List<Map<String, dynamic>>.from(sales);
    // Attach legacy `orderItems` view for each sale.
    for (final sale in list) {
      final details = sale['saleDetails'];
      if (details is List) {
        sale['orderItems'] = details
            .map((d) => _mergeSaleContext(Map<String, dynamic>.from(d), sale))
            .toList();
      } else {
        sale['orderItems'] = <Map<String, dynamic>>[];
      }
    }
    return list;
  }

  /// Returns a flattened list of sale details (legacy order items view)
  /// across all of the current customer's orders.
  static Future<List<Map<String, dynamic>>> fetchOrderItems() async {
    final orders = await fetchOrders();
    final List<Map<String, dynamic>> items = [];
    for (final sale in orders) {
      final details = sale['saleDetails'];
      if (details is List) {
        for (final d in details) {
          items.add(
            _mergeSaleContext(Map<String, dynamic>.from(d), sale),
          );
        }
      }
    }
    return items;
  }

  /// Customer marks their own order as received → backend transitions
  /// status to `completed` and best-effort sets the delivery to delivered.
  static Future<Map<String, dynamic>> confirmReceived({
    required String orderId,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(ConfirmOrderReceived),
          variables: {'id': orderId},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      if (result.hasException) {
        return {'status': false, 'message': result.exception.toString()};
      }
      final payload = result.data?['confirmOrderReceived'];
      if (payload == null) {
        return {'status': false, 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(payload as Map);
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> createReview({
    required String productId,
    required String orderId,
    required int rating,
    required String comment,
    int reviewCount = 1,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(CreateReview),
          variables: {
            'input': {
              'productId': productId,
              // Backend's CreateProductReviewInput names this `saleId`.
              'saleId': orderId,
              'rating': rating,
              'comment': comment,
            },
          },
        ),
      );
      if (result.hasException) {
        return [];
      }
      final payload = result.data?['createReview'];
      if (payload == null) return [];
      // Keep the legacy return type.
      return <Map<String, dynamic>>[Map<String, dynamic>.from(payload as Map)];
    } catch (e) {
      return [];
    }
  }

  /// Translates the Flutter app's legacy order input into the new
  /// `PlaceOrderInput` shape.
  static Map<String, dynamic> _buildPlaceOrderInput(
    Map<String, dynamic> input,
  ) {
    final customerAddressId = input['customerAddressId'] ?? input['shippingAddressId'];
    final note = input['note'];

    final legacyItems = (input['items'] ?? input['orderItems']) as List? ?? [];
    final items = legacyItems.map<Map<String, dynamic>>((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
      final totalPrice = (item['totalPrice'] as num?)?.toDouble() ??
          (unitPrice * quantity);
      final mapped = <String, dynamic>{
        'productId': item['productId'],
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };
      if (item['unitId'] != null) mapped['unitId'] = item['unitId'];
      if (item['unit'] != null) mapped['unit'] = item['unit'];
      if (item['weightGrams'] != null) {
        mapped['weightGrams'] = (item['weightGrams'] as num).toDouble();
      }
      if (item['note'] != null) mapped['note'] = item['note'];
      return mapped;
    }).toList();

    // Payments
    List<Map<String, dynamic>>? payments;
    if (input['payments'] is List) {
      payments = (input['payments'] as List)
          .map<Map<String, dynamic>>((p) {
            final pay = Map<String, dynamic>.from(p as Map);
            final map = <String, dynamic>{
              'paymentMethod': pay['paymentMethod'],
              'currency': pay['currency'] ?? 'LAK',
              'amount': (pay['amount'] as num?)?.toDouble() ?? 0,
            };
            if (pay['slipImageUrl'] != null) {
              map['slipImageUrl'] = pay['slipImageUrl'];
            }
            return map;
          })
          .toList();
    } else if (input['paymentMethod'] != null) {
      final total = items.fold<double>(
        0,
        (sum, item) => sum + (item['totalPrice'] as num).toDouble(),
      );
      final synth = <String, dynamic>{
        'paymentMethod': input['paymentMethod'],
        'currency': input['currency'] ?? 'LAK',
        'amount': total,
      };
      if (input['slipImageUrl'] != null) {
        synth['slipImageUrl'] = input['slipImageUrl'];
      }
      payments = [synth];
    }

    final placeOrder = <String, dynamic>{
      'items': items,
    };
    if (customerAddressId != null) {
      placeOrder['customerAddressId'] = customerAddressId;
    }
    if (note != null) placeOrder['note'] = note;
    if (payments != null && payments.isNotEmpty) {
      placeOrder['payments'] = payments;
    }
    final deliveryService = input['deliveryService'] ?? input['shippingMethod'];
    if (deliveryService != null &&
        deliveryService.toString().trim().isNotEmpty) {
      placeOrder['deliveryService'] = deliveryService;
    }
    final deliveryBranch = input['deliveryBranch'] ?? input['shippingBranch'];
    if (deliveryBranch != null &&
        deliveryBranch.toString().trim().isNotEmpty) {
      placeOrder['deliveryBranch'] = deliveryBranch;
    }
    return placeOrder;
  }

  /// Copies status/saleDate/orderId from the parent sale onto a saleDetail
  /// map so legacy `OrderItem.fromJson` can populate order-level fields.
  static Map<String, dynamic> _mergeSaleContext(
    Map<String, dynamic> detail,
    Map<String, dynamic> sale,
  ) {
    return {
      ...detail,
      'status': sale['status'] ?? 'Processing',
      'saleDate': sale['saleDate'],
      'confirmedAt': sale['confirmedAt'],
      'updatedAt': sale['updatedAt'],
      'orderId': sale['id'],
      'orderCode': sale['code'] ?? '',
      'deliveries': sale['deliveries'] ?? const [],
    };
  }

  static Future<GraphQLClient> _createClient() async {
    final HttpLink httpLink = HttpLink(ApiConstants.graphQlUrl);
    final token = await AuthStorage.getAccessToken();
    Link link = httpLink;
    if (token != null && token.trim().isNotEmpty) {
      final authLink = AuthLink(
        getToken: () async {
          return token;
        },
        headerKey: "Authorization",
      );
      link = authLink.concat(httpLink);
    }
    return GraphQLClient(link: link, cache: GraphQLCache());
  }
}
