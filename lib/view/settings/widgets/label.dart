part of settings_screen;

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveSize.fontSize_14,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
