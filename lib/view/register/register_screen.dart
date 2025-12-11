library register_screen;

import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/view/register/viewmodel/register_viewmodel.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/view/login/widgets/login_input.dart';
import 'package:falcim_benim/view/login/widgets/login_top_icon.dart';
import 'package:falcim_benim/view/login/widgets/primary_gradient_button.dart';
import 'package:falcim_benim/view/login/widgets/google_sign_button.dart';
// removed unused import: login_footer
import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/view/otp/otp_screen.dart';

part 'widgets/register_header.dart';
part 'widgets/register_footer.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 450 ? 420.0 : width * 0.92;

    return Scaffold(
      body: BlocProvider.value(
        value: context.read<RegisterViewModel>()..add(RegisterInitialEvent()),
        child: BlocListener<RegisterViewModel, RegisterState>(
          listener: (context, state) {
            if (state.status == RegisterStatus.success) {
              context.router.replace(const HomeRoute());
            } else if (state.status == RegisterStatus.failure) {
              // Use toast instead of SnackBar
              ToastHelper.showError(
                state.errorMessage ?? AppLocalizations.of(context)!.error,
              );
            }
          },
          child: BlocBuilder<RegisterViewModel, RegisterState>(
            builder: (context, state) {
              final loading = state.status == RegisterStatus.loading;
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_pattern.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LoginTopIcon(),
                          const RegisterHeader(),
                          // Card
                          Container(
                            width: cardWidth,
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
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 8),
                                        LoginInput(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.nameLabel,
                                          hint: AppLocalizations.of(
                                            context,
                                          )!.nameHint,
                                          initialValue: state.name,
                                          focusNode: _nameFocus,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return AppLocalizations.of(
                                                context,
                                              )!.nameRequired;
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (_) {
                                            // if valid, move to phone
                                            if (_formKey.currentState
                                                    ?.validate() ==
                                                true) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(_phoneFocus);
                                            } else {
                                              _nameFocus.requestFocus();
                                            }
                                          },
                                          onChanged: (v) => context
                                              .read<RegisterViewModel>()
                                              .add(UpdateNameEvent(v)),
                                        ),
                                        const SizedBox(height: 16),

                                        LoginInput(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.phoneLabel,
                                          hint: AppLocalizations.of(
                                            context,
                                          )!.phoneHint,
                                          initialValue: state.phone,
                                          focusNode: _phoneFocus,
                                          keyboardType: TextInputType.phone,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return AppLocalizations.of(
                                                context,
                                              )!.phoneRequired;
                                            }
                                            if (!RegExp(
                                              r"^\+?[0-9 ]{7,20}",
                                            ).hasMatch(v.trim())) {
                                              return AppLocalizations.of(
                                                context,
                                              )!.phoneInvalid;
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (_) {
                                            if (_formKey.currentState
                                                    ?.validate() ==
                                                true) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(_ageFocus);
                                            } else {
                                              _phoneFocus.requestFocus();
                                            }
                                          },
                                          onChanged: (v) => context
                                              .read<RegisterViewModel>()
                                              .add(UpdatePhoneEvent(v)),
                                        ),
                                        const SizedBox(height: 16),
                                        // Password removed — authentication is phone+OTP
                                        const SizedBox(height: 8),
                                        // Gender selector
                                        DropdownButtonFormField<String>(
                                          value: state.gender.isNotEmpty
                                              ? state.gender
                                              : null,
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(
                                              context,
                                            )!.genderLabel,
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: 'male',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.genderMale,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'female',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.genderFemale,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'other',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.genderOther,
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => context
                                              .read<RegisterViewModel>()
                                              .add(UpdateGenderEvent(v ?? '')),
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return AppLocalizations.of(
                                                context,
                                              )!.select;
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Marital status selector
                                        DropdownButtonFormField<String>(
                                          value: state.maritalStatus.isNotEmpty
                                              ? state.maritalStatus
                                              : null,
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(
                                              context,
                                            )!.maritalLabel,
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: 'single',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.maritalSingle,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'married',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.maritalMarried,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'other',
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.maritalOther,
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => context
                                              .read<RegisterViewModel>()
                                              .add(
                                                UpdateMaritalStatusEvent(
                                                  v ?? '',
                                                ),
                                              ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return AppLocalizations.of(
                                                context,
                                              )!.select;
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Age input
                                        LoginInput(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.ageLabel,
                                          hint: '30',
                                          initialValue:
                                              state.age?.toString() ?? '',
                                          keyboardType: TextInputType.number,
                                          focusNode: _ageFocus,
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return AppLocalizations.of(
                                                context,
                                              )!.ageRequired;
                                            final n = int.tryParse(v);
                                            if (n == null || n <= 0)
                                              return AppLocalizations.of(
                                                context,
                                              )!.ageInvalid;
                                            return null;
                                          },
                                          onFieldSubmitted: (_) {
                                            if (_formKey.currentState
                                                    ?.validate() ==
                                                true) {
                                              FocusScope.of(context).unfocus();
                                            } else {
                                              _ageFocus.requestFocus();
                                            }
                                          },
                                          onChanged: (v) => context
                                              .read<RegisterViewModel>()
                                              .add(
                                                UpdateAgeEvent(int.tryParse(v)),
                                              ),
                                        ),
                                        const SizedBox(height: 18),
                                        PrimaryGradientButton(
                                          onPressed: loading
                                              ? null
                                              : () async {
                                                  // Validate entire form before proceeding
                                                  final valid =
                                                      _formKey.currentState
                                                          ?.validate() ??
                                                      false;
                                                  if (!valid) {
                                                    ToastHelper.showError(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.fillAllFields,
                                                    );
                                                    return;
                                                  }
                                                  final phone = state.phone
                                                      .trim();
                                                  if (phone.isEmpty) {
                                                    ToastHelper.showError(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.phoneRequired,
                                                    );
                                                    return;
                                                  }
                                                  // Navigate to OTP screen and wait for verification
                                                  final ok =
                                                      await Navigator.of(
                                                        context,
                                                      ).push<bool?>(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              OtpScreen(
                                                                initialPhone:
                                                                    phone,
                                                              ),
                                                        ),
                                                      );
                                                  if (ok == true) {
                                                    // finalize signup in viewmodel
                                                    context
                                                        .read<
                                                          RegisterViewModel
                                                        >()
                                                        .add(
                                                          SignUpCompletedEvent(),
                                                        );
                                                  }
                                                },
                                          loading: loading,
                                          label: AppLocalizations.of(
                                            context,
                                          )!.registerButton,
                                        ),

                                        const SizedBox(height: 12),
                                        RegisterFooter(
                                          onForgot: () {},
                                          onRegister: () => context.router
                                              .replace(const LoginRoute()),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
