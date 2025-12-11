import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

class GoogleSignButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const GoogleSignButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        icon: const CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFFE8F0FE),
          child: Icon(Icons.search, size: 16, color: Color(0xFF4285F4)),
        ),
        onPressed: loading ? null : onPressed,
        label: Text(
          AppLocalizations.of(context)!.googleContinue,
          style: const TextStyle(color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}
