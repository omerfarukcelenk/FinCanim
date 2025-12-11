import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
// model import not needed here
import 'package:flutter_bloc/flutter_bloc.dart';
import 'viewmodel/history_viewmodel.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';
import 'package:falcim_benim/view/detail/detail_screen.dart';
import 'package:falcim_benim/view/history/widgets/history_card.dart';
import 'viewmodel/history_event.dart';
import 'viewmodel/history_state.dart';

@RoutePage()
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
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
          AppLocalizations.of(context)!.historyTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: ResponsiveSize.fontSize_20,
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(ResponsiveSize.padding_12),
              child: BlocBuilder<HistoryViewmodel, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryInitial) {
                    // dispatch load when first built
                    context.read<HistoryViewmodel>().add(
                      const HistoryLoadEvent(),
                    );
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HistoryError) {
                    return Center(
                      child: Text(
                        'Hata: ${state.message}',
                        style: TextStyle(
                          fontSize: ResponsiveSize.fontSize_14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (state is HistoryEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noHistory,
                        style: TextStyle(
                          fontSize: ResponsiveSize.fontSize_16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  }

                  if (state is HistoryLoaded) {
                    final items = state.readings;
                    return ListView.separated(
                      padding: EdgeInsets.only(
                        top: ResponsiveSize.padding_8,
                        bottom: ResponsiveSize.padding_24,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: ResponsiveSize.padding_12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                          key: ValueKey(item.key),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            context.read<HistoryViewmodel>().add(
                              HistoryDeleteEvent(index: index),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveSize.padding_12,
                            ),
                            color: Theme.of(context).colorScheme.error,
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                          child: HistoryCard(
                            item: item,
                            index: index,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(index: index),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
