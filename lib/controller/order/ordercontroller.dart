import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/graphql/orders/mutation.dart';
import 'package:plant_aplication/graphql/orders/query.dart';
import 'package:plant_aplication/services/authHelper.dart';
import 'package:plant_aplication/services/authStorage.dart';

class CreateOrderController {
  static Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> input,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(CreateOrder),
          variables: {'input': input},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }

      return result.data!['createOrder'];
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final client = await _createClient();
    final result = await client.query(QueryOptions(document: gql(QueryOrder)));

    if (result.hasException) {
      print(result.exception.toString());
      return [];
    }

    final data = result.data?["orders"]?["data"];
    if (data == null) return [];

    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> fetchOrderItems() async {
    final client = await _createClient();
    final result = await client.query(
      QueryOptions(document: gql(QuerorderItems)),
    );
    if (result.hasException) {
      return [];
    }
    final list = result.data?['orderItems']?['data'];
    if (list == null) return [];
    return List<Map<String, dynamic>>.from(list);
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
