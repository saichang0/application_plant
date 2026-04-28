import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/graphql/product/mutation.dart';
import 'package:plant_aplication/graphql/product/query.dart';
import 'package:plant_aplication/services/authHelper.dart';
import 'package:plant_aplication/services/authStorage.dart';

class ProductController {
  // Query product list from the public customer-facing resolver.
  static Future<List<Map<String, dynamic>>> queryProducts({
    String? keyword,
    int? page,
    int? limit,
    bool? isSpecialOffer,
    bool? isPopular,
    String? shopId,
  }) async {
    await checkTokenAndLogout();
    final client = await _createClient();

    final Map<String, dynamic> variables = {};

    if (keyword != null && keyword.trim().isNotEmpty) {
      variables['keyword'] = keyword;
    }

    if (page != null && limit != null) {
      variables['paginate'] = {'page': page, 'limit': limit};
    }

    // ✅ FIX FILTER (no null values)
    if (isSpecialOffer != null || isPopular != null) {
      final filter = <String, dynamic>{};

      if (isSpecialOffer != null) {
        filter['isSpecialOffer'] = isSpecialOffer;
      }

      if (isPopular != null) {
        filter['isPopular'] = isPopular;
      }

      variables['filter'] = filter;
    }

    if (shopId != null && shopId.trim().isNotEmpty) {
      variables['shopId'] = shopId;
    }

    final result = await client.query(
      QueryOptions(
        document: gql(ProductsQuery),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      debugPrint('queryProducts exception: ${result.exception}');
      throw Exception(result.exception.toString());
    }

    final data = result.data?['publicProducts']?['data'] as List?;
    debugPrint(
      'queryProducts (filter=${variables['filter']}) -> ${data?.length ?? 0} items',
    );
    if (data == null) return [];

    return List<Map<String, dynamic>>.from(data);
  }

  // Query a single product by id.
  static Future<Map<String, dynamic>> fetchProduct({
    String? id,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.query(
        QueryOptions(document: gql(Product), variables: {'id': id}),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final payload = result.data?['publicProduct'];
      if (payload == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(payload as Map);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  // Toggle wishlist for a product.
  static Future<Map<String, dynamic>> togglewishlist({
    required String productId,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(ToggleWishlist),
          variables: {'productId': productId},
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final data = result.data?['toggleWishlist'];
      if (data == null) {
        return {'status': 'ERROR', 'message': 'Empty response'};
      }
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  // Query wishlist for the current customer.
  static Future<List<Map<String, dynamic>>> wishlist() async {
    await checkTokenAndLogout();
    final client = await _createClient();
    final result = await client.query(
      QueryOptions(
        document: gql(Wishlist),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      debugPrint('wishlist exception: ${result.exception}');
      throw Exception(result.exception.toString());
    }
    debugPrint('wishlist raw data: ${result.data}');
    final data = result.data?['wishlists']?['data'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
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
