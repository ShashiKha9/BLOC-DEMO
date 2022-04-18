import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/persists/data_manager.dart';
import 'package:rescu_organization_portal/data/persists/token_store.dart';

// Events
abstract class ChangePasswordEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitChangePassword extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;

  SubmitChangePassword(this.oldPassword, this.newPassword);

  @override
  List<Object> get props => [oldPassword, newPassword];
}

// State
abstract class ChangePasswordState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChangePasswordInitialState extends ChangePasswordState {}

class ChangePasswordLoadingState extends ChangePasswordState {}

class ChangePasswordSuccessState extends ChangePasswordState {}

class ChangePasswordFailedState extends ChangePasswordState {}

class ChangePasswordUnknownErrorState extends ChangePasswordState {}

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ITokenStore _tokenStore;
  final IAuthenticationApi _authenticationApi;
  final IDataManager _dataManager;
  ChangePasswordBloc(
      this._tokenStore, this._authenticationApi, this._dataManager)
      : super(ChangePasswordInitialState());

  @override
  Stream<ChangePasswordState> mapEventToState(
      ChangePasswordEvent event) async* {
    if (event is SubmitChangePassword) {
      yield ChangePasswordLoadingState();

      var result = await _authenticationApi.changePassword(
          event.oldPassword, event.newPassword);

      if (result is Ok) {
        await _dataManager.clearAll();
        await _tokenStore.delete();
        yield ChangePasswordSuccessState();
        return;
      }
      if (result is Bad && result.statusCode == HttpStatus.badRequest) {
        // yield ChangePasswordSuccessState();
        // return;
        yield ChangePasswordFailedState();
        return;
      }
      yield ChangePasswordUnknownErrorState();
    }
  }
}
