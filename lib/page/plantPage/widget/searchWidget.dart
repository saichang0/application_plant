import 'package:flutter/material.dart';
import 'package:plant_aplication/constant/colorConst.dart';

class SearchWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            hintText: 'Search',
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
