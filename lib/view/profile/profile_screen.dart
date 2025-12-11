import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/view/profile/viewmodel/profile_viewmodel.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/view/profile/widgets/profile_header.dart';
import 'package:falcim_benim/view/profile/widgets/stat_card.dart';
import 'package:falcim_benim/view/profile/widgets/menu_item_tile.dart';
import 'package:falcim_benim/view/profile/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/utils/toast_helper.dart';

part 'widgets/profile_body.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: context.read<ProfileViewmodel>()..add(ProfileInitialEvent()),
        child: BlocConsumer<ProfileViewmodel, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.signedOut) {
              context.router.replaceAll([const LoginRoute()]);
            } else if (state.status == ProfileStatus.failure) {
              ToastHelper.showError(
                state.errorMessage ?? AppLocalizations.of(context)!.error,
              );
            }
          },
          builder: (context, state) {
            return ProfileBody(state: state);
          },
        ),
      ),
    );
  }
}
