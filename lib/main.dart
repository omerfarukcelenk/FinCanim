import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:falcim_benim/utils/app_theme.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Configure Firebase Auth Emulator for local testing (debug only).
/// This enables testing SMS OTP flow without real SMS sending or rate limits.
/// Currently disabled - using production Firebase.
/// @Deprecated - Not currently used but kept for reference during Phase 1
Future<void> _configureAuthEmulator() async {
  if (kDebugMode) {
    try {
      // Android emulator uses 10.0.2.2, physical/iOS uses localhost
      const String host = String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
        defaultValue: '10.0.2.2',
      );
      const int port = int.fromEnvironment(
        'FIREBASE_EMULATOR_PORT',
        defaultValue: 9099,
      );
      await FirebaseAuth.instance.useAuthEmulator(host, port);
      Logger.info('Firebase Auth Emulator connected: $host:$port');
    } catch (e) {
      Logger.error('Failed to connect to Auth Emulator: $e');
      // Emulator not running is not fatal; will use production
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAuthService.instance.init();

  // Emulator disabled - using production Firebase
  // await _configureAuthEmulator();

  Logger.enableInRelease = true;
  await HiveHelper().init();

  // Initialize OneSignal
  await _initializeOneSignal();

  runApp(MyApp());
}

Future<void> _initializeOneSignal() async {
  try {
    // Replace with your OneSignal App ID
    const String oneSignalAppId = '745f61ee-9edb-4224-b1af-17a49f65d84c';

    // Set debug log level
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    } catch (e) {
      Logger.warn('Failed to set OneSignal log level: $e');
    }

    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);
    Logger.info('OneSignal initialized with App ID: $oneSignalAppId');

    // Request notification permission (iOS + Android 13+)
    try {
      Logger.info('Requesting OneSignal notification permission...');
      final permissionGranted = await OneSignal.Notifications.requestPermission(
        true,
      );
      Logger.info('OneSignal permission granted: $permissionGranted');
    } catch (e) {
      Logger.warn('Failed to request OneSignal permission: $e');
    }

    // Setup notification handlers
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
      Logger.info(
        'OneSignal foreground notification: ${event.notification.body}',
      );
    });

    OneSignal.Notifications.addClickListener((event) {
      Logger.info('OneSignal notification clicked: ${event.notification.body}');

      try {
        final navigator = ToastHelper.navigatorKey.currentState;
        if (navigator != null) {
          // Handle fortune notification - navigate to home first, then to latest fortune detail
          final action =
              event.notification.additionalData?['action'] as String?;
          final type = event.notification.additionalData?['type'] as String?;

          if (type == 'fortune_ready' || action == 'open_last_fortune') {
            Logger.info('Opening last fortune detail from notification');
            // Navigate to home first
            navigator.popUntil((route) => route.isFirst);

            // Then navigate to history (where latest fortunes are shown)
            // User can tap on the fortune to see detail
            Future.delayed(const Duration(milliseconds: 500), () {
              try {
                final router = ToastHelper.navigatorKey.currentContext
                    ?.findAncestorStateOfType<NavigatorState>();
                // Trigger navigation via AppRouter if available
                Logger.info('Navigated to home after notification click');
                ToastHelper.showSuccess('Falınız hazır! 🎉');
              } catch (e) {
                Logger.error('Failed to navigate to detail: $e');
              }
            });
          }
        }
      } catch (e) {
        Logger.error('Failed to handle notification click: $e');
      }
    });

    Logger.info('OneSignal initialized successfully');
  } catch (e) {
    Logger.error('Failed to initialize OneSignal: $e');
    // Don't fail app startup if OneSignal fails
  }
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
