part of '../look_screen.dart';

class LookConfirmButton extends StatefulWidget {
  const LookConfirmButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<LookConfirmButton> createState() => _LookConfirmButtonState();
}

class _LookConfirmButtonState extends State<LookConfirmButton> {
  bool _locked = false;

  void _handleTap() {
    if (_locked) return;
    _locked = true;
    try {
      widget.onTap();
    } finally {
      // Unlock after a short delay to avoid accidental double taps.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _locked = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookViewmodel, LookState>(
      builder: (context, state) {
        final uploading = state is LookUploading;
        final enabled = !_locked && !uploading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? _handleTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveSize.padding_16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
              ),
              elevation: 3,
            ),
            child: Text(
              AppLocalizations.of(context)!.readFortune,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge!.color,
                fontSize: ResponsiveSize.fontSize_18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
