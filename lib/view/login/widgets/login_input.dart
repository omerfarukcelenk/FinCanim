import 'package:flutter/material.dart';

class LoginInput extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;

  const LoginInput({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue = '',
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          obscureText: obscure,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          keyboardType:
              keyboardType ??
              (obscure ? TextInputType.text : TextInputType.emailAddress),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
