import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/graphql/product/mutation.dart';
import 'package:plant_aplication/graphql/product/query.dart';
import 'package:plant_aplication/services/authHelper.dart';
import 'package:plant_aplication/services/authStorage.dart';

class ProductController {
  // query product data
  static Future<List<Map<String, dynamic>>> queryProducts({
    String? keyword,
    int? page,
    int? limit,
    bool? isSpecialOffer,
    bool? isPopular,
  }) async {
    await checkTokenAndLogout();
    final client = await _createClient();
    Map<String, dynamic> variables = {};
    if (keyword != null && keyword.trim().isNotEmpty) {
      variables['keyword'] = keyword;
    }
    if (page != null && limit != null) {
      variables['paginate'] = {'page': page, 'limit': limit};
    }
    if (isSpecialOffer != null || isPopular != null) {
      variables['filter'] = {
        'isSpecialOffer': isSpecialOffer,
        'isPopular': isPopular,
      };
    }
    final result = await client.query(
      QueryOptions(document: gql(ProductsQuery), variables: variables),
    );
    if (result.hasException) {
      return [];
    }
    final data = result.data?["products"]?["data"];
    print('product data $data');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  //query product by id, name, price
  static Future<Map<String, dynamic>> fetchProduct({
    String? id,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final Map<String, dynamic> where = {};
      final result = await client.query(
        QueryOptions(
          document: gql(Product),
          variables: {
            'where': {'_id': id},
          },
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      return Map<String, dynamic>.from(result.data?['product'] as Map);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  //create and delete wishlist
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

  // query wishlist data
  static Future<List<Map<String, dynamic>>> wishlist() async {
    final client = await _createClient();
    final result = await client.query(QueryOptions(document: gql(Wishlist)));
    if (result.hasException) {
      return [];
    }
    final Data = result.data?["wishlists"]?["data"];
    if (Data == null) return [];
    return List<Map<String, dynamic>>.from(Data);
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
