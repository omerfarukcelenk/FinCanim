import 'package:falcim_benim/data/models/user_model.dart';

class HomeState {
  final UserModel? userModel;

  HomeState({this.userModel});

  HomeState copyWith({UserModel? userModel}) {
    return HomeState(userModel: userModel ?? this.userModel);
  }
}
