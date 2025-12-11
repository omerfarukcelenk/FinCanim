part of settings_screen;

class RoundedPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggle;
  final String? Function(String?)? validator;

  const RoundedPasswordField(
    this.controller,
    this.obscure,
    this.toggle, {
    super.key,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      decoration: InputDecoration(
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
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}
