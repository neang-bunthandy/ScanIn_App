// Reusable search bar widget for Web Admin tables.
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AdminSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final double width;

  const AdminSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, size: 19, color: AppColors.primary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'សម្អាត',
                  icon: const Icon(Icons.close_rounded, size: 17),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        style: const TextStyle(fontSize: 13.5),
      ),
    );
  }
}
