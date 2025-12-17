import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/constant/countyData.dart';
import 'package:plant_aplication/controller/user/addressController.dart';
import 'package:plant_aplication/model/address.dart';
import 'package:plant_aplication/page/cartPage/shipping.dart';
import 'package:plant_aplication/until/toast.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final raw = await AddressController.userAddresses();
    final addresses = raw
        .asMap()
        .entries
        .map((entry) => Address.fromJson(entry.value, entry.key))
        .toList();

    ref.read(addressListProvider.notifier).setAddresses(addresses);

    // Select default address if exists
    final selected = ref.read(selectedAddressProvider);
    if (selected == null) {
      final defaultAddress = addresses.isNotEmpty
          ? addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            )
          : null;
      ref.read(selectedAddressProvider.notifier).state = defaultAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressListProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shipping Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: addresses.isEmpty
                ? const Center(
                    child: Text(
                      'No address yet. Please add one.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isSelected = selectedAddress?.id == address.id;

                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(30 * (1 - value), 0),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedAddressCard(
                            address: address,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedAddressProvider.notifier).state =
                                  address;
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _showAddressSelector(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorConstants.buttonColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Add New Address',
                      style: TextStyle(
                        color: ColorConstants.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final addresses = ref.read(addressListProvider);
                      if (addresses.isEmpty) {
                        ToastHelper.showWarning(
                          context,
                          'No Address',
                          'Please add at least one address before proceeding.',
                        );
                        return;
                      }
                      final selected = ref.read(selectedAddressProvider);
                      if (selected == null) {
                        ToastHelper.showWarning(
                          context,
                          'No Default Address',
                          'Please select or add a default address before proceeding.',
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShippingPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AddressSelectorBottomSheet();
      },
    );
  }
}

class _AddressSelectorBottomSheet extends ConsumerStatefulWidget {
  const _AddressSelectorBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<_AddressSelectorBottomSheet> createState() =>
      _AddressSelectorBottomSheetState();
}

class _AddressSelectorBottomSheetState
    extends ConsumerState<_AddressSelectorBottomSheet> {
  Province? selectedProvince;
  District? selectedDistrict;
  Village? selectedVillage;

  List<District> availableDistricts = [];
  List<Village> availableVillages = [];

  bool isLoading = false;
  String displayName({required String lo, required String en}) {
    return lo.isNotEmpty ? lo : en;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Select Your Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Province",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Province>(
              value: selectedProvince,
              decoration: _inputDecoration(),
              hint: const Text('Select Province'),
              items: AddressData.provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(
                    displayName(lo: province.nameLo, en: province.nameEn),
                  ),
                );
              }).toList(),
              onChanged: (province) {
                setState(() {
                  selectedProvince = province;
                  selectedDistrict = null;
                  selectedVillage = null;
                  if (province != null) {
                    availableDistricts = AddressData.getDistrictsByProvince(
                      province.id,
                    );
                  } else {
                    availableDistricts = [];
                  }
                  availableVillages = [];
                });
              },
            ),
            const SizedBox(height: 18),
            const Text(
              "District",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<District>(
              value: selectedDistrict,
              decoration: _inputDecoration(),
              hint: const Text('Select District'),
              items: availableDistricts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(
                    displayName(lo: district.nameLo, en: district.nameEn),
                  ),
                );
              }).toList(),
              onChanged: selectedProvince == null
                  ? null
                  : (district) {
                      setState(() {
                        selectedDistrict = district;
                        selectedVillage = null;

                        if (district != null) {
                          availableVillages = AddressData.getVillagesByDistrict(
                            district.id,
                          );
                        } else {
                          availableVillages = [];
                        }
                      });
                    },
            ),
            const SizedBox(height: 18),
            const Text(
              "Village",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Village>(
              value: selectedVillage,
              decoration: _inputDecoration(),
              hint: const Text('Select Village'),
              items: availableVillages.map((village) {
                return DropdownMenuItem(
                  value: village,
                  child: Text(
                    displayName(lo: village.nameLo, en: village.nameEn),
                  ),
                );
              }).toList(),
              onChanged: selectedDistrict == null
                  ? null
                  : (village) {
                      setState(() {
                        selectedVillage = village;
                      });
                    },
            ),

            const SizedBox(height: 30),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: ColorConstants.buttonColor),
                      backgroundColor: ColorConstants.buttonColor.withOpacity(
                        0.05,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: ColorConstants.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (selectedProvince == null ||
                            selectedDistrict == null ||
                            selectedVillage == null ||
                            isLoading)
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            final result =
                                await AddressController.createAddress(
                                  province: displayName(
                                    lo: selectedProvince!.nameLo,
                                    en: selectedProvince!.nameEn,
                                  ),
                                  district: displayName(
                                    lo: selectedDistrict!.nameLo,
                                    en: selectedDistrict!.nameEn,
                                  ),
                                  village: displayName(
                                    lo: selectedVillage!.nameLo,
                                    en: selectedVillage!.nameEn,
                                  ),
                                  context: context,
                                );

                            setState(() {
                              isLoading = false;
                            });
                            print('result $result');

                            if (result['status'] == true) {
                              final data = result['data'];
                              final newAddress = Address(
                                id: data['_id'].toString(),
                                province: displayName(
                                  lo: selectedProvince!.nameLo,
                                  en: selectedProvince!.nameEn,
                                ),
                                district: displayName(
                                  lo: selectedDistrict!.nameLo,
                                  en: selectedDistrict!.nameEn,
                                ),
                                village: displayName(
                                  lo: selectedVillage!.nameLo,
                                  en: selectedVillage!.nameEn,
                                ),
                                icon: Icons.home,
                              );
                              ref
                                  .read(addressListProvider.notifier)
                                  .addAddress(newAddress);

                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ?? 'Error saving address',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: ColorConstants.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class AnimatedAddressCard extends StatefulWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedAddressCard({
    Key? key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedAddressCard> createState() => _AnimatedAddressCardState();
}

class _AnimatedAddressCardState extends State<AnimatedAddressCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: widget.isSelected ? const Color(0xFFE6FFF9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? ColorConstants.buttonColor
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? ColorConstants.buttonColor.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: widget.isSelected ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? ColorConstants.buttonColor.withOpacity(0.2)
                    : ColorConstants.buttonColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.address.icon,
                color: ColorConstants.buttonColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.address.village,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.address.address,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? ColorConstants.buttonColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? ColorConstants.buttonColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
