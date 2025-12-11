part of '../profile_screen.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, required this.state});
  final ProfileState state;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_pattern.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // subtle overlay to keep content readable
              Positioned.fill(
                child: Container(color: const Color.fromRGBO(0, 0, 0, 0.06)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: ResponsiveSize.height_50),
                    ProfileHeader(
                      name: state.name.isNotEmpty
                          ? state.name
                          : AppLocalizations.of(context)!.appTitle,
                      email: state.email,
                      onAvatarTap: () {},
                    ),
                    SizedBox(height: ResponsiveSize.height_50 / 1.50),
                    // combined stats + menu sheet
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              blurRadius: 6,
                              spreadRadius: 0.5,
                              offset: Offset(0, 5),
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: ResponsiveSize.height_50 / 1.5),

                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      value: '${state.totalReadings}',
                                      label: AppLocalizations.of(
                                        context,
                                      )!.profileTotalReadings,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: StatCard(
                                      value: '${state.remainingRights}',
                                      label: AppLocalizations.of(
                                        context,
                                      )!.profileRemainingRights,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: ResponsiveSize.padding_12),

                            // small pill and menu items
                            MenuItemTile(
                              icon: Icons.settings,
                              title: AppLocalizations.of(context)!.menuSettings,
                              onTap: () =>
                                  context.router.push(const SettingsRoute()),
                            ),
                            const SizedBox(height: 12),
                            MenuItemTile(
                              icon: Icons.workspace_premium,
                              title: AppLocalizations.of(context)!.menuPremium,
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            MenuItemTile(
                              icon: Icons.help,
                              title: AppLocalizations.of(context)!.menuHelp,
                              onTap: () {},
                            ),
                            SizedBox(height: ResponsiveSize.padding_12),
                            MenuItemTile(
                              icon: Icons.info,
                              title: AppLocalizations.of(context)!.menuAbout,
                              onTap: () {},
                            ),
                            SizedBox(height: ResponsiveSize.height_50 / 1.1),
                            LogoutButton(
                              onPressed: () => context
                                  .read<ProfileViewmodel>()
                                  .add(ProfileSignOutEvent()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
