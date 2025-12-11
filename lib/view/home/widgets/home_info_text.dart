part of '../home_screen.dart';

class InfoText extends StatelessWidget {
  const InfoText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ResponsiveSize.padding_8),
      height: ResponsiveSize.height_100 * 1.3,
      width: ResponsiveSize.width_300 * 1.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(238, 12, 57, 1),
            Color.fromRGBO(143, 2, 2, 1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.homeCallToAction,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveSize.fontSize_28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 3),
                    blurRadius: 0.3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            Text(
              AppLocalizations.of(context)!.homeSubtitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveSize.fontSize_16,
                shadows: [
                  Shadow(
                    offset: Offset(0, 3),
                    blurRadius: 0.3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
