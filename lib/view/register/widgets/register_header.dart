part of register_screen;

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.registerButton,
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
          AppLocalizations.of(context)!.registerSubtitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveSize.fontSize_16,
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
