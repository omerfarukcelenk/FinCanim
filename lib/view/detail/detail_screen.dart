// dart:io not needed here; image handled in widget

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'viewmodel/detail_viewmodel.dart';
import 'viewmodel/detail_event.dart';
import 'viewmodel/detail_state.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'widgets/detail_image.dart';
import 'widgets/detail_comment.dart';
import 'package:falcim_benim/utils/reading_parser.dart';
import 'widgets/detail_actions.dart';

@RoutePage()
class DetailScreen extends StatelessWidget {
  final int? index;
  final String? fortuneId;

  const DetailScreen({super.key, this.index, this.fortuneId});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);

    // Use index or default to 0
    int displayIndex = index ?? 0;
    return Scaffold(
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
        title: Text(
          AppLocalizations.of(context)!.falResult,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: ResponsiveSize.fontSize_24,
            fontWeight: FontWeight.bold,
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
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<DetailViewmodel, DetailState>(
          listener: (context, state) {
            if (state is DetailSaved) {
              ToastHelper.showSuccess(AppLocalizations.of(context)!.saved);
            }
            if (state is DetailError) {
              final prefix = AppLocalizations.of(context)!.error;
              ToastHelper.showError('$prefix: ${state.message}');
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveSize.padding_12),
                  child: BlocBuilder<DetailViewmodel, DetailState>(
                    builder: (context, state) {
                      // trigger load when in initial state
                      if (state is DetailInitial) {
                        // dispatch load and show loader while loading
                        context.read<DetailViewmodel>().add(
                          DetailLoadEvent(index: displayIndex),
                        );
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is DetailLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is DetailLoaded) {
                        final item = state.reading;
                        final int? age = state.userAge;
                        final parts = parseReadingIntoCategories(item.reading);

                        // Photos at top (slider), then category tabs for the comment
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Photo slider placed at top
                            DetailImages(imagePaths: item.imagePaths),
                            SizedBox(height: ResponsiveSize.padding_12),

                            // Tabs for categorized reading
                            DefaultTabController(
                              length: 7,
                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: TabBar(
                                        isScrollable: true,
                                        labelColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        unselectedLabelColor: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                        indicatorColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        tabs: const [
                                          Tab(text: '📖 Başlangıç'),
                                          Tab(text: '🔮 GENEL YORUM'),
                                          Tab(text: '❤️ AŞK VE İLİŞKİLER'),
                                          Tab(text: '💼 KARİYER VE İŞ'),
                                          Tab(text: '🌟 GELECEK VE FIRSATLAR'),
                                          Tab(text: '💰 MADDİ DURUM'),
                                          Tab(
                                            text:
                                                '⚠️ DİKKAT EDİLMESİ GEREKENLER',
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSize.padding_12),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          // Başlangıç
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading:
                                                    parts['baslangic']
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? parts['baslangic']!
                                                    : item.reading,
                                                userAge: age,
                                                categoryTitle: '📖 Başlangıç',
                                              ),
                                            ),
                                          ),

                                          // GENEL YORUM
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['genel'] ?? '',
                                                userAge: age,
                                                categoryTitle: '🔮 GENEL YORUM',
                                              ),
                                            ),
                                          ),

                                          // AŞK VE İLİŞKİLER
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['ask'] ?? '',
                                                userAge: age,
                                                categoryTitle:
                                                    '❤️ AŞK VE İLİŞKİLER',
                                              ),
                                            ),
                                          ),

                                          // KARİYER VE İŞ
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['kariyer'] ?? '',
                                                userAge: age,
                                                categoryTitle:
                                                    '💼 KARİYER VE İŞ',
                                              ),
                                            ),
                                          ),

                                          // GELECEK VE FIRSATLAR
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['gelecek'] ?? '',
                                                userAge: age,
                                                categoryTitle:
                                                    '🌟 GELECEK VE FIRSATLAR',
                                              ),
                                            ),
                                          ),

                                          // MADDİ DURUM
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['maddi'] ?? '',
                                                userAge: age,
                                                categoryTitle: '💰 MADDİ DURUM',
                                              ),
                                            ),
                                          ),

                                          // DİKKAT EDİLMESİ GEREKENLER
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: DetailComment(
                                                reading: parts['dikkat'] ?? '',
                                                userAge: age,
                                                categoryTitle:
                                                    '⚠️ DİKKAT EDİLMESİ GEREKENLER',
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
                          ],
                        );
                      }

                      if (state is DetailError) {
                        final prefix = AppLocalizations.of(context)!.error;
                        return Center(child: Text('$prefix: ${state.message}'));
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
