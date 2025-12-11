import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

typedef VoidCallback = void Function();

class DetailActions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onReturn;

  const DetailActions({
    super.key,
    required this.onSave,
    required this.onShare,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSave,
                icon: Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  loc.save,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: ResponsiveSize.fontSize_14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveSize.padding_12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSize.radius_12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveSize.padding_12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  loc.share,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: ResponsiveSize.fontSize_14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveSize.padding_12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSize.radius_12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveSize.padding_16),

        ElevatedButton(
          onPressed: onReturn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(vertical: ResponsiveSize.padding_16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
            ),
            elevation: 6,
          ),
          child: Text(
            loc.backToHome,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: ResponsiveSize.fontSize_18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
