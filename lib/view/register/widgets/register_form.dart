part of register_screen;

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode passwordConfirmFocus;
  final FocusNode ageFocus;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.passwordConfirmFocus,
    required this.ageFocus,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterViewModel, RegisterState>(
      builder: (context, state) {
        return Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildNameField(context, state),
              const SizedBox(height: 16),
              _buildEmailField(context, state),
              const SizedBox(height: 16),
              _buildPasswordField(context, state),
              const SizedBox(height: 16),
              _buildPasswordConfirmField(context, state),
              const SizedBox(height: 16),
              _buildGenderField(context, state),
              const SizedBox(height: 16),
              _buildMaritalStatusField(context, state),
              const SizedBox(height: 16),
              _buildAgeField(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context, RegisterState state) {
    return LoginInput(
      label: AppLocalizations.of(context)!.nameLabel,
      hint: AppLocalizations.of(context)!.nameHint,
      initialValue: state.name,
      focusNode: widget.nameFocus,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return AppLocalizations.of(context)!.nameRequired;
        }
        return null;
      },
      onFieldSubmitted: (_) => _onFieldSubmitted(widget.emailFocus),
      onChanged: (v) =>
          context.read<RegisterViewModel>().add(UpdateNameEvent(v)),
    );
  }

  Widget _buildEmailField(BuildContext context, RegisterState state) {
    return LoginInput(
      label: 'Email',
      hint: 'user@example.com',
      initialValue: state.email,
      focusNode: widget.emailFocus,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Lütfen e-posta girin';
        }
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
      onFieldSubmitted: (_) => _onFieldSubmitted(widget.passwordFocus),
      onChanged: (v) =>
          context.read<RegisterViewModel>().add(UpdateEmailEvent(v)),
    );
  }

  Widget _buildPasswordField(BuildContext context, RegisterState state) {
    return LoginInput(
      label: 'Şifre',
      hint: '••••••••',
      initialValue: state.password,
      focusNode: widget.passwordFocus,
      obscure: true,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Lütfen şifre girin';
        }
        if (v.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
      onFieldSubmitted: (_) => _onFieldSubmitted(widget.passwordConfirmFocus),
      onChanged: (v) =>
          context.read<RegisterViewModel>().add(UpdatePasswordEvent(v)),
    );
  }

  Widget _buildPasswordConfirmField(BuildContext context, RegisterState state) {
    return LoginInput(
      label: 'Şifre Onayla',
      hint: '••••••••',
      initialValue: state.passwordConfirm,
      focusNode: widget.passwordConfirmFocus,
      obscure: true,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Lütfen şifreyi onaylayın';
        }
        return null;
      },
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      onChanged: (v) =>
          context.read<RegisterViewModel>().add(UpdatePasswordConfirmEvent(v)),
    );
  }

  Widget _buildGenderField(BuildContext context, RegisterState state) {
    return DropdownButtonFormField<String>(
      value: state.gender.isNotEmpty ? state.gender : 'Erkek',
      items: [
        DropdownMenuItem(
          value: 'Erkek',
          child: Text(AppLocalizations.of(context)!.genderMale),
        ),
        DropdownMenuItem(
          value: 'Kadın',
          child: Text(AppLocalizations.of(context)!.genderFemale),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<RegisterViewModel>().add(UpdateGenderEvent(value));
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.genderLabel,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMaritalStatusField(BuildContext context, RegisterState state) {
    return DropdownButtonFormField<String>(
      value: state.maritalStatus.isNotEmpty ? state.maritalStatus : 'Bekar',
      items: [
        DropdownMenuItem(
          value: 'Bekar',
          child: Text(AppLocalizations.of(context)!.maritalSingle),
        ),
        DropdownMenuItem(
          value: 'Evli',
          child: Text(AppLocalizations.of(context)!.maritalMarried),
        ),
        DropdownMenuItem(
          value: 'Diğer',
          child: Text(AppLocalizations.of(context)!.maritalOther),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<RegisterViewModel>().add(
            UpdateMaritalStatusEvent(value),
          );
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.maritalLabel,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAgeField(BuildContext context, RegisterState state) {
    return LoginInput(
      label: AppLocalizations.of(context)!.ageLabel,
      hint: AppLocalizations.of(context)!.ageLabel,
      initialValue: state.age.toString(),
      focusNode: widget.ageFocus,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return AppLocalizations.of(context)!.ageRequired;
        }
        final n = int.tryParse(v);
        if (n == null || n <= 0) {
          return AppLocalizations.of(context)!.ageInvalid;
        }
        return null;
      },
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      onChanged: (v) => context.read<RegisterViewModel>().add(
        UpdateAgeEvent(int.tryParse(v) ?? 0),
      ),
    );
  }

  void _onFieldSubmitted(FocusNode nextFocus) {
    if (widget.formKey.currentState?.validate() == true) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }
}
