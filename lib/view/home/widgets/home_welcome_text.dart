part of '../home_screen.dart';

class WelcomeText extends StatefulWidget {
  const WelcomeText({super.key});

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText> {
  late Future<String> planFuture;

  @override
  void initState() {
    super.initState();
    planFuture = _getPlanFromFirebase();
  }

  Future<String> _getPlanFromFirebase() async {
    try {
      final premium = await PremiumService().getPremiumDetails();
      return premium?.plan ?? 'free';
    } catch (e) {
      print('Error getting plan: $e');
      return 'free';
    }
  }

  Map<String, dynamic> _getPlanConfig(String plan) {
    switch (plan.toLowerCase()) {
      case 'basic':
        return {
          'label': 'BASIC',
          'bgColor': Color(0xFF1976D2), // Blue
        };
      case 'premium':
        return {
          'label': 'PREMIUM',
          'bgColor': Color(0xFFD4AF37), // Gold
        };
      case 'pro':
        return {
          'label': 'PRO',
          'bgColor': Color(0xFFE91E63), // Pink/Magenta
        };
      default: // 'free'
        return {
          'label': 'FREE',
          'bgColor': Color(0xFF757575), // Gray
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.welcomeGreeting,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveSize.fontSize_32,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 3),
                    blurRadius: 0.3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveSize.padding_8),
            Text(
              AppLocalizations.of(context)!.welcomePrompt,
              style: TextStyle(
                fontSize: ResponsiveSize.fontSize_20,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 3),
                    blurRadius: 0.3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Profile / avatar button with Premium badge underneath
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => context.router.push(const ProfileRoute()),
              borderRadius: BorderRadius.circular(28),
              child: CircleAvatar(
                radius: ResponsiveSize.radius_30,
                backgroundColor: const Color(0xFFFFC107),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF4A148C),
                  size: ResponsiveSize.icon_32 * 1.2,
                ),
              ),
            ),
            SizedBox(height: ResponsiveSize.height_50 / 4.5),
            // Plan badge (dynamic based on Firestore)
            FutureBuilder<String>(
              future: planFuture,
              builder: (context, snapshot) {
                final plan = snapshot.data ?? 'free';
                final config = _getPlanConfig(plan);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: config['bgColor'],
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(64),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    config['label'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveSize.fontSize_12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
