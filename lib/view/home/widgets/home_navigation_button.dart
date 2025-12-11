part of '../home_screen.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final String icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ResponsiveSize.height_100,
        width: ResponsiveSize.width_300 * 1.2,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).shadowColor.withAlpha((0.3 * 255).round()),
              blurRadius: 0.5,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: ResponsiveSize.padding_16),
            Container(
              height: ResponsiveSize.height_50 / 1.1,
              width: ResponsiveSize.height_50 / 1.1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 50, 1, 1),
                    Color.fromRGBO(255, 123, 0, 1), // #FFAE00
                  ],
                  stops: [0.0, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: ResponsiveSize.padding_8 / 3,
                ),
                borderRadius: BorderRadius.circular(ResponsiveSize.radius_4),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: ResponsiveSize.fontSize_28),
                ),
              ),
            ),
            SizedBox(width: ResponsiveSize.padding_16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSize.fontSize_24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveSize.fontSize_18,
                    color: Theme.of(context).textTheme.labelMedium!.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
