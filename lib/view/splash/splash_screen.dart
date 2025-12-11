import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_event.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_state.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    return BlocBuilder<SplashViewmodel, SplashState>(
      bloc: context.read<SplashViewmodel>()
        ..add(SplashInitialEvent(context: context)),
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_pattern.png'),
                fit: BoxFit.fill,
              ),
            ),
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(ResponsiveSize.padding_20),
                      padding: EdgeInsets.all(ResponsiveSize.padding_20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(255, 204, 0, 0.877), // #FFCC00
                            Color.fromRGBO(255, 191, 0, 1), // #FFBF00
                            Color.fromRGBO(255, 123, 0, 1), // #FFAE00
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: ResponsiveSize.padding_8 / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveSize.radius_16,
                        ),
                      ),
                      child: Text(
                        '☕',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: ResponsiveSize.fontSize_32 * 3,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveSize.padding_8),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: ResponsiveSize.fontSize_28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveSize.padding_4),
                    Text(
                      AppLocalizations.of(context)!.splashSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: ResponsiveSize.fontSize_14,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: EdgeInsets.symmetric(
                    vertical: ResponsiveSize.padding_20,
                    horizontal: ResponsiveSize.padding_20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha((0.5 * 255).round()),
                        width: ResponsiveSize.padding_8 / 2,
                      ),
                      right: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha((0.5 * 255).round()),
                        width: ResponsiveSize.padding_8 / 2,
                      ),
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha((0.5 * 255).round()),
                        width: ResponsiveSize.padding_8 / 2,
                      ),
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha((0.5 * 255).round()),
                        width: ResponsiveSize.padding_8 / 2,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveSize.radius_20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
