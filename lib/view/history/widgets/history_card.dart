import 'dart:io';
import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/data/models/coffee_reading_model.dart';
import 'package:intl/intl.dart';

typedef HistoryTapCallback = void Function();

class HistoryCard extends StatelessWidget {
  final CoffeeReadingModel item;
  final int index;
  final HistoryTapCallback? onTap;

  const HistoryCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  String _excerpt(String text, {int maxChars = 120}) {
    if (text.length <= maxChars) return text;
    return text.substring(0, maxChars) + '...';
  }

  String _formatDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    try {
      return DateFormat('d MMMM yyyy', locale).format(d);
    } catch (_) {
      return '${d.day} ${d.month} ${d.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(context, item.createdAt);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius_12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((0.7 * 255).round()),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.padding_12,
          vertical: ResponsiveSize.padding_12,
        ),
        leading: Container(
          width: ResponsiveSize.width_100 / 2.5,
          height: ResponsiveSize.width_100 / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Builder(
              builder: (context) {
                final paths = item.imagePaths;
                if (paths.isNotEmpty) {
                  final p = paths.first;
                  try {
                    final f = File(p);
                    if (p.isNotEmpty && f.existsSync()) {
                      return Image.file(
                        f,
                        width: ResponsiveSize.width_100 / 2.5,
                        height: ResponsiveSize.width_100 / 2.5,
                        fit: BoxFit.cover,
                      );
                    }
                  } catch (_) {}
                }

                // Placeholder with coffee emoji
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: Text(
                      '☕',
                      style: TextStyle(fontSize: ResponsiveSize.icon_32),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        title: Text(
          dateStr,
          style: TextStyle(
            fontSize: ResponsiveSize.fontSize_12,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: ResponsiveSize.padding_8),
          child: Text(
            _excerpt(item.reading),
            style: TextStyle(
              fontSize: ResponsiveSize.fontSize_14,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
