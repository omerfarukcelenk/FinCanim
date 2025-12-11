import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback? onForgot;
  final VoidCallback? onRegister;

  const LoginFooter({super.key, this.onForgot, this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.noAccountPrompt),
            TextButton(
              onPressed: onRegister,
              child: Text(
                AppLocalizations.of(context)!.registerButton,
                style: const TextStyle(color: Color(0xFFd32f2f)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
