import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/services/premium_service.dart';
import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:falcim_benim/view/home/viewmodel/home_event.dart';
import 'package:falcim_benim/view/home/viewmodel/home_state.dart';
import 'package:falcim_benim/view/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/l10n/app_localizations.dart';

part 'widgets/home_body.dart';
part 'widgets/home_item_cheack.dart';
part 'widgets/home_welcome_text.dart';
part 'widgets/home_drag_handle.dart';
part 'widgets/home_info_text.dart';
part 'widgets/home_navigation_button.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    return Scaffold(
      body: BlocBuilder<HomeViewmodel, HomeState>(
        bloc: context.read<HomeViewmodel>()..add(HomeInitialEvent()),
        builder: (context, state) {
          return HomeBody();
        },
      ),
    );
  }
}
