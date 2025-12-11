part of settings_screen;

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const RoundedTextField({
    super.key,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? Theme.of(context).colorScheme.onPrimary : Colors.grey,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
