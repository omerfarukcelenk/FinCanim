part of '../look_screen.dart';

class LookUploadCard extends StatelessWidget {
  const LookUploadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookViewmodel, LookState>(
      builder: (context, state) {
        final paths = state is LookSelected ? state.paths : <String>[];
        final hasImage = paths.isNotEmpty;

        return Container(
          width: double.infinity,
          height: ResponsiveSize.height_300,
          padding: EdgeInsets.all(ResponsiveSize.padding_16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: ResponsiveSize.height_300 / 1.12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(ResponsiveSize.radius_12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Stack(
                  children: [
                    if (hasImage) ...[
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSize.radius_12,
                          ),
                          child: Image.file(
                            File(paths.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: ResponsiveSize.icon_20,
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(context)!.delete,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.deleteConfirm,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text(
                                        AppLocalizations.of(context)!.delete,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                context.read<LookViewmodel>().add(
                                  DeletePhotoEvent(paths.first),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        right: 8,
                        child: SizedBox(
                          height: 68,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final needAddButton = paths.length < 3;
                              final addIndex = paths.length;
                              if (needAddButton && index == addIndex) {
                                return GestureDetector(
                                  onTap: () => context
                                      .read<LookViewmodel>()
                                      .add(const SelectPhotoEvent()),
                                  child: Container(
                                    width: 80,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final p = paths[index];
                              final fileExists =
                                  p.isNotEmpty && File(p).existsSync();
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: fileExists
                                        ? Image.file(
                                            File(p),
                                            width: 80,
                                            height: 64,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 80,
                                            height: 64,
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final vm = context
                                            .read<LookViewmodel>();
                                        final confirmed =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.delete,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.deleteConfirm,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(false),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.cancel,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(true),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.delete,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                        if (confirmed == true) {
                                          vm.add(DeletePhotoEvent(p));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 8),
                            itemCount:
                                paths.length + (paths.length < 3 ? 1 : 0),
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: ResponsiveSize.icon_48,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(height: ResponsiveSize.padding_12),
                            Text(
                              AppLocalizations.of(context)!.newReadingSubtitle,
                              style: TextStyle(
                                fontSize: ResponsiveSize.fontSize_18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            SizedBox(height: ResponsiveSize.padding_8),
                            Text(
                              AppLocalizations.of(context)!.choosePhoto,
                              style: TextStyle(
                                fontSize: ResponsiveSize.fontSize_14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: ResponsiveSize.padding_12),
                            ElevatedButton(
                              onPressed: () async {
                                context.read<LookViewmodel>().add(
                                  const SelectPhotoEvent(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveSize.padding_12,
                                  horizontal: ResponsiveSize.padding_24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveSize.radius_12,
                                  ),
                                ),
                                elevation: 6,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.selectPhoto,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveSize.fontSize_16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state is LookLoading)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color.fromARGB(90, 255, 255, 255),
                        ),
                      ),
                    if (state is LookLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
