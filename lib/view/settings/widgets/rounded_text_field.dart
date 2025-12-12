part of settings_screen;

class RoundedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  const RoundedTextField({
    super.key,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<RoundedTextField> createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      obscureText: _obscure,
      style: TextStyle(
        color: widget.enabled
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.grey,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
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
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
