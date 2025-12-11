import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/view/otp/viewmodel/otp_viewmodel.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  final String? initialPhone; // optional pre-filled phone
  const OtpScreen({super.key, this.initialPhone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final OtpViewModel _vm = OtpViewModel();
  Timer? _resendTimer;
  int _resendSeconds = 0;
  static const int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) _phoneCtrl.text = widget.initialPhone!;
    // If initialPhone provided, send code using viewmodel
    if (widget.initialPhone != null) {
      // call directly on the viewmodel instance created here
      _vm.sendCode(widget.initialPhone!);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _vm.close();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneCtrl.text.trim();
    _vm.sendCode(phone);
  }

  Future<void> _onResendPressed() async {
    if (_resendSeconds > 0) return;
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    _vm.sendCode(phone, forceResend: true);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _resendSeconds -= 1;
      });
      if (_resendSeconds <= 0) {
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> _onVerifyPressed() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    _vm.verifyCode(code);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.phoneLabel ?? 'Phone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSize.padding_16),
          child: BlocProvider.value(
            value: _vm,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocListener<OtpViewModel, OtpState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        ToastHelper.showError(state.error!);
                      }
                      if (state.codeSent) {
                        ToastHelper.showInfo(
                          AppLocalizations.of(context)!.sendCode,
                        );
                        _startResendTimer();
                      }
                      if (state.verified) {
                        ToastHelper.showSuccess(
                          AppLocalizations.of(context)!.verify,
                        );
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  Text(
                    AppLocalizations.of(context)!.otpInstruction,
                    style: TextStyle(fontSize: ResponsiveSize.fontSize_16),
                  ),
                  SizedBox(height: ResponsiveSize.padding_16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneLabel,
                      hintText: AppLocalizations.of(context)!.phoneHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return AppLocalizations.of(context)!.phoneRequired;
                      if (!RegExp(r"^\+?[0-9 ]{7,20}").hasMatch(v.trim()))
                        return AppLocalizations.of(context)!.phoneInvalid;
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  BlocBuilder<OtpViewModel, OtpState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: state.sending ? null : _onSendPressed,
                            child: state.sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(AppLocalizations.of(context)!.sendCode),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: (state.sending || _resendSeconds > 0)
                                ? null
                                : _onResendPressed,
                            child: Text(
                              _resendSeconds > 0
                                  ? '${AppLocalizations.of(context)!.resend} ($_resendSeconds s)'
                                  : AppLocalizations.of(context)!.resend,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveSize.padding_20),
                  TextFormField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.codeLabel,
                      hintText: AppLocalizations.of(context)!.codeHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  BlocBuilder<OtpViewModel, OtpState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.verifying ? null : _onVerifyPressed,
                        child: state.verifying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.verify),
                      );
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
