part of settings_screen;

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  late String _gender;
  late String _marital;

  final TextEditingController _currentPwdCtrl = TextEditingController();
  final TextEditingController _newPwdCtrl = TextEditingController();
  final TextEditingController _newPwd2Ctrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureNew2 = true;
  bool _lastSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize with defaults, will be updated by BlocListener
    _gender = 'Erkek';
    _marital = 'Bekar';
    // Trigger viewmodel to load user data from Firestore
    context.read<SettingsViewmodel>().loadInitial();
  }

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _newPwd2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsViewmodel, SettingsState>(
      listener: (context, state) {
        if (!mounted) return;
        // update simple UI-only values with validation
        final genderOptions = [
          AppLocalizations.of(context)!.genderMale,
          AppLocalizations.of(context)!.genderFemale,
        ];
        final maritalOptions = [
          AppLocalizations.of(context)!.maritalSingle,
          AppLocalizations.of(context)!.maritalMarried,
          AppLocalizations.of(context)!.maritalOther,
        ];

        final newGender =
            (state.gender != null &&
                state.gender!.isNotEmpty &&
                genderOptions.contains(state.gender))
            ? state.gender!
            : 'Erkek';

        final newMarital =
            (state.maritalStatus != null &&
                state.maritalStatus!.isNotEmpty &&
                maritalOptions.contains(state.maritalStatus))
            ? state.maritalStatus!
            : 'Bekar';

        setState(() {
          _gender = newGender;
          _marital = newMarital;
        });

        if (_lastSaving && !state.saving) {
          ToastHelper.showSuccess(AppLocalizations.of(context)!.changesSaved);
          // Navigate back to the app's home/root screen after successful save
          try {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {
            // ignore navigation failure, keep app stable
            print('Navigation after save failed: $e');
          }
        }
        _lastSaving = state.saving;
      },
      child: BlocBuilder<SettingsViewmodel, SettingsState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveSize.padding_12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ResponsiveSize.padding_8),

                  FieldLabel(AppLocalizations.of(context)!.nameLabel),
                  RoundedTextField(
                    controller: context
                        .read<SettingsViewmodel>()
                        .nameController,
                    hint: AppLocalizations.of(context)!.nameHint,
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  FieldLabel('Email'),
                  RoundedTextField(
                    controller: context
                        .read<SettingsViewmodel>()
                        .emailController,
                    hint: 'user@example.com',
                    enabled: false,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 6, left: 6),
                    child: Text(
                      'E-posta değiştirilemez',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),

                  FieldLabel(AppLocalizations.of(context)!.ageLabel),
                  RoundedTextField(
                    controller: context.read<SettingsViewmodel>().ageController,
                    hint: AppLocalizations.of(context)!.ageLabel,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return AppLocalizations.of(context)!.ageRequired;
                      final n = int.tryParse(v);
                      if (n == null || n <= 0)
                        return AppLocalizations.of(context)!.ageInvalid;
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),

                  FieldLabel(AppLocalizations.of(context)!.genderLabel),
                  RoundedDropdown(
                    value: _gender,
                    items: [
                      AppLocalizations.of(context)!.genderMale,
                      AppLocalizations.of(context)!.genderFemale,
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? _gender),
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),

                  FieldLabel(AppLocalizations.of(context)!.maritalLabel),
                  RoundedDropdown(
                    value: _marital,
                    items: [
                      AppLocalizations.of(context)!.maritalSingle,
                      AppLocalizations.of(context)!.maritalMarried,
                      AppLocalizations.of(context)!.maritalOther,
                    ],
                    onChanged: (v) => setState(() => _marital = v ?? _marital),
                  ),
                  SizedBox(height: ResponsiveSize.height_50 / 2),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.saving
                          ? null
                          : () {
                              final vm = context.read<SettingsViewmodel>();
                              vm.saveSettings(
                                name: vm.nameController.text.trim(),
                                age: vm.ageController.text.trim(),
                                gender: _gender,
                                maritalStatus: _marital,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: state.saving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.save,
                              style: TextStyle(
                                fontSize: ResponsiveSize.fontSize_18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveSize.padding_20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
