import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/constant/shipping.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/page/cartPage/payment.dart';
import 'package:plant_aplication/until/appTranslate.dart';

final selectedShippingIndexProvider = StateProvider<int>((ref) => 0);
final selectedShippingBranchProvider = StateProvider<String>((ref) => '');

class ShippingPage extends ConsumerStatefulWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends ConsumerState<ShippingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late final TextEditingController _branchController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _branchController = TextEditingController(
      text: ref.read(selectedShippingBranchProvider),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedShippingIndexProvider);
    final shippingOptions = ShippingConstants.shippingOptions;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: isDark ? Colors.black : Colors.white),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[800]
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'choose_shipping'.tr(language),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: shippingOptions.length,
                    itemBuilder: (context, index) {
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
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ShippingOptionCard(
                            option: shippingOptions[index],
                            isSelected: selectedIndex == index,
                            onTap: () {
                              ref
                                      .read(
                                        selectedShippingIndexProvider.notifier,
                                      )
                                      .state =
                                  index;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Text(
                  'shipping_branch'.tr(language),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _branchController,
                  onChanged: (value) {
                    ref.read(selectedShippingBranchProvider.notifier).state =
                        value.trim();
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'enter_branch_name'.tr(language),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey[900]
                        : const Color(0xFFF8F9FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      final branch = ref
                          .read(selectedShippingBranchProvider)
                          .trim();
                      if (branch.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('branch_required'.tr(language)),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: ColorConstants.gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D9A3).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'apply'.tr(language),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShippingOptionCard extends StatefulWidget {
  final ShippingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const ShippingOptionCard({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ShippingOptionCard> createState() => _ShippingOptionCardState();
}

class _ShippingOptionCardState extends State<ShippingOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: widget.isSelected
              ? isDark
                    ? Colors.grey[800]
                    : const Color(0xFFE6FFF9)
              : isDark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF00D9A3)
                : isDark
                ? Colors.grey[600]!
                : const Color(0xFFE8E8E8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? const Color(0xFF00D9A3).withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: widget.isSelected ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Logo
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D9A3).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                widget.option.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_shipping,
                  color: Color(0xFF00D9A3),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Text(
                widget.option.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFF00D9A3)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF00D9A3)
                      : const Color(0xFFD0D0D0),
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
