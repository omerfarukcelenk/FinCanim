part of '../look_screen.dart';

class LookBody extends StatelessWidget {
  const LookBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveSize.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveSize.padding_8),
                  LookBuildStep(
                    index: 1,
                    title: AppLocalizations.of(context)!.lookStep1Title,
                    subtitle: AppLocalizations.of(context)!.lookStep1Subtitle,
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  LookBuildStep(
                    index: 2,
                    title: AppLocalizations.of(context)!.lookStep2Title,
                    subtitle: AppLocalizations.of(context)!.lookStep2Subtitle,
                  ),
                  SizedBox(height: ResponsiveSize.padding_12),
                  LookBuildStep(
                    index: 3,
                    title: AppLocalizations.of(context)!.lookStep3Title,
                    subtitle: AppLocalizations.of(context)!.lookStep3Subtitle,
                  ),
                  SizedBox(height: ResponsiveSize.height_50 / 1.16),
                  LookUploadCard(),
                  SizedBox(height: ResponsiveSize.height_50 / 1.16),
                  LookConfirmButton(
                    onTap: () {
                      final state = context.read<LookViewmodel>().state;
                      if (state is LookSelected && state.paths.isNotEmpty) {
                        context.read<LookViewmodel>().add(
                          SaveReadingEvent(paths: state.paths),
                        );
                      } else {
                        // prompt user to choose photo
                        ToastHelper.show(
                          AppLocalizations.of(context)!.choosePhoto,
                        );
                      }
                    },
                  ),
                  SizedBox(height: ResponsiveSize.padding_16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
