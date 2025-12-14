import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/view/login/viewmodel/login_viewmodel.dart';

import 'package:falcim_benim/view/login/widgets/login_footer.dart';
import 'package:falcim_benim/view/login/widgets/login_header.dart';
import 'package:falcim_benim/view/login/widgets/login_input.dart';
import 'package:falcim_benim/view/login/widgets/login_top_icon.dart';
import 'package:falcim_benim/view/login/widgets/primary_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/utils/toast_helper.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: context.read<LoginViewModel>()..add(LoginInitialEvent()),
        child: BlocListener<LoginViewModel, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              ToastHelper.showSuccess(
                state.errorMessage ??
                    AppLocalizations.of(context)!.loginSuccess,
              );
              context.router.replace(const HomeRoute());
            } else if (state.status == LoginStatus.failure) {
              ToastHelper.showError(
                state.errorMessage ?? AppLocalizations.of(context)!.loginFailed,
              );
            }
          },
          child: BlocBuilder<LoginViewModel, LoginState>(
            buildWhen: (previous, current) => true,
            builder: (context, state) {
              final loading = state.status == LoginStatus.loading;
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_pattern.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoginTopIcon(),
                        const LoginHeader(),
                        // Card
                        Container(
                          width: ResponsiveSize.width_300 * 1.2,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                spreadRadius: 1,
                                blurRadius: 9,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              // small pill indicator
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 8),
                                    // Email input
                                    LoginInput(
                                      label: 'Email',
                                      hint: 'user@example.com',
                                      initialValue: state.email,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (v) => context
                                          .read<LoginViewModel>()
                                          .add(UpdateEmailEvent(v)),
                                    ),
                                    const SizedBox(height: 16),
                                    // Password input
                                    LoginInput(
                                      label: 'Şifre',
                                      hint: '••••••••',
                                      initialValue: state.password,
                                      obscure: true,
                                      onChanged: (v) => context
                                          .read<LoginViewModel>()
                                          .add(UpdatePasswordEvent(v)),
                                    ),
                                    const SizedBox(height: 18),
                                    PrimaryGradientButton(
                                      onPressed: loading
                                          ? null
                                          : () {
                                              final email = state.email.trim();
                                              final password = state.password;

                                              if (email.isEmpty) {
                                                ToastHelper.showError(
                                                  'Lütfen e-posta girin',
                                                );
                                                return;
                                              }
                                              if (password.isEmpty) {
                                                ToastHelper.showError(
                                                  'Lütfen şifre girin',
                                                );
                                                return;
                                              }

                                              context
                                                  .read<LoginViewModel>()
                                                  .add(SignInCompletedEvent());
                                            },
                                      loading: loading,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.loginButton,
                                    ),

                                    const SizedBox(height: 12),
                                    LoginFooter(
                                      onForgot: () {},
                                      onRegister: () => context.router.push(
                                        const RegisterRoute(),
                                      ),
                                    ),
                                  ],
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
            },
          ),
        ),
      ),
    );
  }
}
