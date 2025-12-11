part of '../look_screen.dart';

class LookBuildStep extends StatelessWidget {
  const LookBuildStep({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
  });
  final int index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // number circle
        Container(
          width: ResponsiveSize.icon_40,
          height: ResponsiveSize.icon_40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveSize.fontSize_24,
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveSize.padding_12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveSize.fontSize_24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSize.padding_4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ResponsiveSize.fontSize_20,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
