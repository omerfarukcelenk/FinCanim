part of '../home_screen.dart';

class HomeDragHandle extends StatelessWidget {
  const HomeDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveSize.padding_20,
        bottom: ResponsiveSize.padding_20,
      ),
      height: ResponsiveSize.height_50 / 9,
      width: ResponsiveSize.width_100 / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(143, 2, 2, 1),
            Color.fromRGBO(238, 12, 57, 1),
            Color.fromRGBO(143, 2, 2, 1),
          ],
        ),
      ),
    );
  }
}
