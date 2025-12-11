import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const MenuItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).shadowColor.withAlpha((0.3 * 255).round()),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: ResponsiveSize.icon_32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color,
                    fontSize: ResponsiveSize.fontSize_18,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Color(0xFFB71C1C),
                size: ResponsiveSize.icon_32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
