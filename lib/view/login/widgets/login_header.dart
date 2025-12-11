import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.loginWelcomeTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveSize.fontSize_32,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 3),
                blurRadius: 0.3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.loginWelcomeSubtitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveSize.fontSize_18,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 0.3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
