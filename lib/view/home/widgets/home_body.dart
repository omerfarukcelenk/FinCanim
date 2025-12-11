part of '../home_screen.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_pattern.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveSize.height_50),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSize.padding_12,
              ),
              child: WelcomeText(),
            ),
            SizedBox(height: ResponsiveSize.height_50),
            HomeItemCheack(),
          ],
        ),
      ),
    );
  }
}
