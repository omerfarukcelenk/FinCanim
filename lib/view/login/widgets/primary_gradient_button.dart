import 'package:flutter/material.dart';

class PrimaryGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  const PrimaryGradientButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFb71c1c), Color(0xFF7f0000)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Center(
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
