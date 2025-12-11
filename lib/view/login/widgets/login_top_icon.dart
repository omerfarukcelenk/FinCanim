import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class LoginTopIcon extends StatelessWidget {
  const LoginTopIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveSize.height_150,
      width: ResponsiveSize.height_150,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: ResponsiveSize.padding_8 / 2,
        ),
        borderRadius: BorderRadius.circular(ResponsiveSize.radius_8),
      ),
      child: Image.asset(
        'assets/icon/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            '☕',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveSize.fontSize_32 * 2.2,
            ),
          ),
        ),
      ),
    );
  }
}
