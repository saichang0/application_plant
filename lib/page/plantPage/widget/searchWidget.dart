import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/until/appTranslate.dart';

class SearchWidget extends ConsumerWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final FocusNode? focusNode;

  const SearchWidget({
    Key? key,
    this.controller,
    this.onChanged,
    this.onFilterPressed,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(languageProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          focusNode: focusNode,
          autofocus: false,
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) {
            if (onFilterPressed != null) {
              onFilterPressed!();
            }
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'search'.tr(language),
            hintStyle: TextStyle(
              color: isDark ? Colors.white : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.grey[400],
            ),
            suffixIcon: InkWell(
              onTap: onFilterPressed,
              child: const Icon(
                Icons.tune,
                color: ColorConstants.primaryColor,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
