import 'package:TEST/data/persists/data_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class LogoutEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Logout extends LogoutEvent {}

// State
abstract class LogoutState extends Equatable {
  @override
  List<Object> get props => [];
}

class LogoutInitialState extends LogoutState {}

class LogoutLoadingState extends LogoutState {}

class LogoutSuccessState extends LogoutState {}

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final IDataManager _dataManager;
  LogoutBloc(this._dataManager) : super(LogoutInitialState());

  @override
  Stream<LogoutState> mapEventToState(LogoutEvent event) async* {
    if (event is Logout) {
      yield LogoutLoadingState();
      await _dataManager.clearAll();
      yield LogoutSuccessState();
    }
  }
}
