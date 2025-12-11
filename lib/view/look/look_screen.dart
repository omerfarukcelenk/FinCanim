import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/view/look/viewmodel/look_viewmodel.dart';
import 'package:falcim_benim/view/look/viewmodel/look_state.dart';
import 'package:falcim_benim/view/look/viewmodel/look_event.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/toast_helper.dart';

part 'widgets/look_build_step.dart';
part 'widgets/look_upload_card.dart';
part 'widgets/look_confirm_button.dart';
part 'widgets/look_body.dart';

@RoutePage()
class LookScreen extends StatelessWidget {
  const LookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    return BlocProvider(
      create: (context) => LookViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 2,
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
              color: Theme.of(context).colorScheme.onPrimary,
              size: ResponsiveSize.icon_24,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.lookTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: ResponsiveSize.fontSize_20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<LookViewmodel, LookState>(
          listener: (context, state) async {
            if (state is LookUploading) {
              // show blocking loading dialog
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    // WillPopScope is deprecated; keep here to prevent back-button during blocking dialog.
                    // ignore: deprecated_member_use
                    WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        content: Row(
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(width: ResponsiveSize.padding_12),
                            Expanded(
                              child: Text(
                                'Falınız bakılıyor, lütfen bekleyiniz',
                                style: TextStyle(
                                  fontSize: ResponsiveSize.fontSize_14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            } else if (state is LookSaved) {
              // dismiss loading dialog if present
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (_) {}
              // show ready message and navigate to detail
              ToastHelper.showSuccess('Falınız hazır');
              // navigate to Detail page with saved index
              context.router.push(DetailRoute(index: state.key));
            } else if (state is LookError) {
              // dismiss loading dialog if present
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (_) {}
              ToastHelper.showError('Error: ${state.message}');
            }
          },
          child: LookBody(),
        ),
      ),
    );
  }
}
