library settings_screen;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/view/settings/viewmodel/settings_viewmodel.dart';

part 'widgets/settings_form.dart';
part 'widgets/section_title.dart';
part 'widgets/label.dart';
part 'widgets/rounded_text_field.dart';
part 'widgets/rounded_dropdown.dart';
part 'widgets/password_field.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);

    return BlocProvider(
      create: (_) => SettingsViewmodel()..loadInitial(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_pattern2.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              size: ResponsiveSize.icon_20,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          title: Text(
            'Ayarlar',
            style: TextStyle(
              fontSize: ResponsiveSize.fontSize_20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        body: const SafeArea(child: SettingsForm()),
      ),
    );
  }
}
