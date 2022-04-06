import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/persists/data_manager.dart';
import 'package:rescu_organization_portal/data/persists/token_store.dart';

// States
abstract class SplashState extends Equatable {
  @override
  List<Object> get props => [];
}

class SplashInitialState extends SplashState {}

class SplashLoadingState extends SplashState {}

class SplashShouldMoveToDashboard extends SplashState {}

class SplashShouldMoveToLogin extends SplashState {}

// Events
abstract class SplashEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SplashDetermineMove extends SplashEvent {}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ITokenStore _tokenStore;
  final IDataManager _dataManager;

  SplashBloc(this._tokenStore, this._dataManager) : super(SplashInitialState());

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is SplashDetermineMove) {
      yield SplashLoadingState();
      var isLoggedIn = await _tokenStore.isLoggedIn();
      if (isLoggedIn) {
        yield SplashShouldMoveToDashboard();
        return;
      } else {
        await _dataManager.clearAll();
        yield SplashShouldMoveToLogin();
        return;
      }
    }
  }
}
