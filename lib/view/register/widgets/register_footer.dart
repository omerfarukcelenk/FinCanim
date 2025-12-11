part of register_screen;

class RegisterFooter extends StatelessWidget {
  final VoidCallback? onForgot;
  final VoidCallback? onRegister;

  const RegisterFooter({super.key, this.onForgot, this.onRegister});
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
                AppLocalizations.of(context)!.loginButton,
                style: const TextStyle(color: Color(0xFFd32f2f)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
