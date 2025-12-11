import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  Future<void> _confirmAndLogout(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          loc.logoutConfirmTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveSize.fontSize_28,
          ),
        ),
        content: Text(
          loc.logoutConfirmMessage,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveSize.fontSize_16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.yes),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        onPressed();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _confirmAndLogout(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFFB71C1C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.black54,
          elevation: 6,
        ),
        child: Text(
          AppLocalizations.of(context)!.logout,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveSize.fontSize_20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
