import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/graphql/address/mutation.dart';
import 'package:plant_aplication/graphql/address/query.dart';
import 'package:plant_aplication/services/authHelper.dart';
import 'package:plant_aplication/services/authStorage.dart';

class AddressController {
  static Future<Map<String, dynamic>> createAddress({
    required String province,
    required String district,
    required String village,
    String country = 'Laos',
    bool isDefault = false,
    required BuildContext context,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(CreateAddress),
          variables: {
            'input': {
              'province': province,
              'district': district,
              'village': village,
              'country': country,
              'isDefault': isDefault,
            },
          },
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final response = result.data?['createCustomerAddress'];

      if (response == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'status': 'ERROR', 'message': 'Something went wrong: $e'};
    }
  }

  static Future<List<Map<String, dynamic>>> userAddresses() async {
    try {
      final client = await _createClient();
      final result = await client.query(
        QueryOptions(
          document: gql(QueryAddress),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) {
        debugPrint(result.exception.toString());
        return [];
      }
      final response = result.data?['customerAddresses'];
      if (response == null || response['status'] != true) {
        return [];
      }

      final List list = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateAddress({
    required String id,
    String? province,
    String? district,
    String? village,
    String? country,
    bool? isDefault,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final data = <String, dynamic>{};
      if (province != null) data['province'] = province;
      if (district != null) data['district'] = district;
      if (village != null) data['village'] = village;
      if (country != null) data['country'] = country;
      if (isDefault != null) data['isDefault'] = isDefault;

      final result = await client.mutate(
        MutationOptions(
          document: gql(UpdateAddress),
          variables: {
            'input': {'id': id, 'data': data},
          },
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final response = result.data?['updateCustomerAddress'];
      if (response == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress({required String id}) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(DeleteAddress),
          variables: {
            'input': {'id': id},
          },
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final response = result.data?['deleteCustomerAddress'];
      if (response == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress({
    required String id,
  }) async {
    try {
      await checkTokenAndLogout();
      final client = await _createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(SetDefaultAddress),
          variables: {'id': id},
        ),
      );
      if (result.hasException) {
        return {'status': 'ERROR', 'message': result.exception.toString()};
      }
      final response = result.data?['setDefaultCustomerAddress'];
      if (response == null) {
        return {'status': 'ERROR', 'message': 'Empty response from server'};
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'status': 'ERROR', 'message': e.toString()};
    }
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
