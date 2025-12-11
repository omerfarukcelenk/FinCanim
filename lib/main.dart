import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/utils/logger.dart';
import 'package:falcim_benim/view/home/viewmodel/home_viewmodel.dart';
import 'package:falcim_benim/view/login/viewmodel/login_viewmodel.dart';
import 'package:falcim_benim/view/look/viewmodel/look_viewmodel.dart';
import 'package:falcim_benim/view/otp/viewmodel/otp_viewmodel.dart';
import 'package:falcim_benim/view/profile/viewmodel/profile_viewmodel.dart';
import 'package:falcim_benim/view/register/viewmodel/register_viewmodel.dart';
import 'package:falcim_benim/view/settings/viewmodel/settings_viewmodel.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_viewmodel.dart';
import 'package:falcim_benim/view/history/viewmodel/history_viewmodel.dart';
import 'package:falcim_benim/view/detail/viewmodel/detail_viewmodel.dart';
import 'package:flutter/material.dart';
// localization handled by generated AppLocalizations
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:falcim_benim/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAuthService.instance.init();
  Logger.enableInRelease = true;
  await HiveHelper().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter(navigatorKey: ToastHelper.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashViewmodel()),
        BlocProvider(create: (context) => HomeViewmodel()),
        BlocProvider(create: (context) => HistoryViewmodel()),
        BlocProvider(create: (context) => DetailViewmodel()),
        BlocProvider(create: (context) => LookViewmodel()),
        BlocProvider(create: (context) => LookViewmodel()),
        BlocProvider(create: (context) => RegisterViewModel()),
        BlocProvider(create: (context) => LoginViewModel()),
        BlocProvider(create: (context) => ProfileViewmodel()),
        BlocProvider(create: (context) => SettingsViewmodel()),
        BlocProvider(create: (context) => OtpViewModel()),
      ],
      child: MaterialApp.router(
        title: AppLocalizations.of(context)?.appTitle ?? 'My Coffee Readings',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return const Locale('tr');
          for (var supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) return supported;
          }
          return const Locale('tr');
        },
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
