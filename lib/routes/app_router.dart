import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/view/detail/detail_screen.dart';
import 'package:falcim_benim/view/history/history_screen.dart';
import 'package:falcim_benim/view/home/home_screen.dart';
import 'package:falcim_benim/view/look/look_screen.dart';
import 'package:falcim_benim/view/login/login_screen.dart';
import 'package:falcim_benim/view/profile/profile_screen.dart';
import 'package:falcim_benim/view/register/register_screen.dart';
import 'package:falcim_benim/view/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import '../view/splash/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  AppRouter({super.navigatorKey});
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: LookRoute.page),
    AutoRoute(page: HistoryRoute.page),
    AutoRoute(page: DetailRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}
