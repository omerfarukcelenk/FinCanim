library register_screen;

import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/view/register/viewmodel/register_viewmodel.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/view/login/widgets/login_input.dart';
import 'package:falcim_benim/view/login/widgets/login_top_icon.dart';
import 'package:falcim_benim/view/login/widgets/primary_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'widgets/register_header.dart';
part 'widgets/register_footer.dart';
part 'widgets/register_form.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: context.read<RegisterViewModel>()..add(RegisterInitialEvent()),
        child: BlocListener<RegisterViewModel, RegisterState>(
          listener: _handleStateListener,
          child: BlocBuilder<RegisterViewModel, RegisterState>(
            buildWhen: (previous, current) => true,
            builder: (context, state) {
              return _buildBody(context, state);
            },
          ),
        ),
      ),
    );
  }

  void _handleStateListener(BuildContext context, RegisterState state) {
    if (state.status == RegisterStatus.success) {
      context.router.replace(const HomeRoute());
    } else if (state.status == RegisterStatus.failure) {
      ToastHelper.showError(
        state.errorMessage ?? AppLocalizations.of(context)!.error,
      );
    }
  }

  Widget _buildBody(BuildContext context, RegisterState state) {
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
                _buildFormCard(context, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, RegisterState state) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 450 ? 420.0 : width * 0.92;
    final loading = state.status == RegisterStatus.loading;

    return Container(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegisterForm(
                  formKey: _formKey,
                  nameFocus: _nameFocus,
                  emailFocus: _emailFocus,
                  passwordFocus: _passwordFocus,
                  passwordConfirmFocus: _passwordConfirmFocus,
                  ageFocus: _ageFocus,
                ),
                const SizedBox(height: 18),
                _buildSubmitButton(context, loading),
                const SizedBox(height: 12),
                RegisterFooter(
                  onForgot: () {},
                  onRegister: () => context.router.replace(const LoginRoute()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool loading) {
    return PrimaryGradientButton(
      onPressed: loading ? null : _onSignUpPressed,
      loading: loading,
      label: AppLocalizations.of(context)!.registerButton,
    );
  }

  void _onSignUpPressed() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ToastHelper.showError(AppLocalizations.of(context)!.fillAllFields);
      return;
    }
    context.read<RegisterViewModel>().add(SignUpCompletedEvent());
  }
}
