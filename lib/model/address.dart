import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class Address {
  final String? id;
  final String province;
  final String district;
  final String village;
  final IconData icon;
  final bool isDefault;

  Address({
    this.id,
    required this.province,
    required this.district,
    required this.village,
    required this.icon,
    this.isDefault = false,
  });

  String get address => '$village, $district, $province';

  factory Address.fromJson(Map<String, dynamic> json, [int? index]) {
    final provinceIcons = {
      'ນະຄອນຫລວງວຽງຈັນ': Icons.location_city,
      'Vientiane capital': Icons.location_city,
      'ຜົ້ງສາລີ': Icons.terrain,
      'Phongsali': Icons.terrain,
      'ຫລວງນ້ຳທາ': Icons.water,
      'Louang Namtha': Icons.water,
      'ອຸດົມໄຊ': Icons.forest,
      'Oudomxai': Icons.forest,
      'ບໍ່ແກ້ວ': Icons.store,
      'Bokeo': Icons.store,
      'ຫຼວງພະບາງ': Icons.landscape,
      'Louang Phabang': Icons.landscape,
      'ຫົວພັນ': Icons.hiking,
      'Houaphan': Icons.hiking,
      'ໄຊຍະບູລີ': Icons.map,
      'Xaignabouli': Icons.map,
      'ຊຽງຂວາງ': Icons.add_home_work,
      'Xiangkhoang': Icons.add_home_work,
      'ວຽງຈັນ': Icons.location_on,
      'Vientiane': Icons.location_on,
      'ບໍລິຄຳໄຊ': Icons.business,
      'Boli khamxai': Icons.business,
      'ຄຳມ່ວນ': Icons.local_florist,
      'Khammouan': Icons.local_florist,
      'ສະຫວັນນະເຂດ': Icons.grass,
      'Savannakhet': Icons.grass,
      'ສາລະວັນ': Icons.landscape,
      'Salavan': Icons.landscape,
      'ເຊກອງ': Icons.park,
      'Xekong': Icons.park,
      'ຈຳປາສັກ': Icons.beach_access,
      'Champasak': Icons.beach_access,
      'ອັດຕະປື': Icons.agriculture,
      'Attapu': Icons.agriculture,
      'ໄຊສົມບູນ': Icons.terrain,
      'Sisomboun': Icons.terrain,
    };

    final provinceName = json['province'] ?? '';
    final icon = provinceIcons[provinceName] ?? Icons.location_on;

    return Address(
      id: json['_id']?.toString() ?? UniqueKey().toString(),
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      village: json['village'] ?? '',
      icon: icon,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'district': district,
      'village': village,
      'isDefault': isDefault,
    };
  }
}

// Selected Address Provider
final selectedAddressProvider = StateProvider<Address?>((ref) => null);

// Available Addresses Provider
final addressListProvider =
    StateNotifierProvider<AddressNotifier, List<Address>>(
      (ref) => AddressNotifier(),
    );

class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super([]);

  void setAddresses(List<Address> addresses) {
    state = addresses;
  }

  void addAddress(Address address) {
    state = [...state, address];
  }
}
