part of '../home_screen.dart';

class HomeItemCheack extends StatelessWidget {
  const HomeItemCheack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveSize.height_300 * 2.2,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((0.5 * 255).round()),
            blurRadius: 3,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveSize.radius_30),
          topRight: Radius.circular(ResponsiveSize.radius_30),
        ),
      ),
      child: Column(
        children: [
          HomeDragHandle(),
          InfoText(),
          SizedBox(height: ResponsiveSize.padding_16),
          NavigationButton(
            onTap: () {
              // Check user's remaining fortune slots before navigating
              PremiumService()
                  .canReadFortune()
                  .then((can) {
                    if (can) {
                      context.router.push(LookRoute());
                    } else {
                      ToastHelper.showError('Kullanım hakkınız kalmadı');
                    }
                  })
                  .catchError((e) {
                    // On error, show message and prevent navigation
                    ToastHelper.showError(
                      'İnceleme kontrolü sırasında hata oluştu',
                    );
                  });
            },
            icon: '📷',
            title: AppLocalizations.of(context)!.newReadingTitle,
            subtitle: AppLocalizations.of(context)!.newReadingSubtitle,
          ),
          SizedBox(height: ResponsiveSize.padding_16),
          NavigationButton(
            onTap: () => context.router.push(HistoryRoute()),
            icon: '📚',
            title: AppLocalizations.of(context)!.historyTitle,
            subtitle: AppLocalizations.of(context)!.historySubtitle,
          ),
          SizedBox(height: ResponsiveSize.padding_16),
          NavigationButton(
            onTap: () {},
            icon: 'ℹ️',
            title: AppLocalizations.of(context)!.howItWorksTitle,
            subtitle: AppLocalizations.of(context)!.howItWorksSubtitle,
          ),
        ],
      ),
    );
  }
}
