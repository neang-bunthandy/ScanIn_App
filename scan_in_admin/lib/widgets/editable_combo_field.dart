import 'package:flutter/material.dart';

/// ប្រអប់បញ្ចូលទិន្នន័យដែលអាចទាំងវាយកំណត់ដោយដៃ (Free Text) និងចុចរើសពីបញ្ជីណែនាំ (Quick Pick)
class EditableComboField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final List<String> suggestions;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry contentPadding;
  final String? clearOptionLabel;

  const EditableComboField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.suggestions,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.clearOptionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: contentPadding,
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'ជ្រើសរើសរហ័ស',
          icon: const Icon(Icons.arrow_drop_down_rounded),
          onSelected: (val) {
            controller.text = val;
            onChanged?.call(val);
          },
          itemBuilder: (ctx) => [
            if (clearOptionLabel != null)
              PopupMenuItem<String>(
                value: '',
                child: Text(clearOptionLabel!),
              ),
            ...suggestions.map(
              (s) => PopupMenuItem<String>(
                value: s,
                child: Text(s, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

