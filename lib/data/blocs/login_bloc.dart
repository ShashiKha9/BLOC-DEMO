import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/login_dto.dart';
import 'package:rescu_organization_portal/data/persists/data_manager.dart';
import 'package:rescu_organization_portal/data/persists/token_store.dart';

// Events
abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitLogin extends LoginEvent {
  final String email;
  final String password;

  SubmitLogin(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class Logout extends LoginEvent {}

// State
abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginInvalidCredentialsState extends LoginState {}

class LoginUnknownErrorState extends LoginState {}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ITokenStore _tokenStore;
  final IAuthenticationApi _authenticationApi;
  final IDataManager _dataManager;
  LoginBloc(this._tokenStore, this._authenticationApi, this._dataManager)
      : super(LoginInitialState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is SubmitLogin) {
      yield LoginLoadingState();

      var result = await _authenticationApi.login(event.email, event.password,
          null, null, null, null, null, null, null, null,
          isPortalRequest: true);

      if (result is OkData<LoginDto>) {
        await _dataManager.clearAll();
        await _tokenStore.save(result.dto.accessToken);
        yield LoginSuccessState();
        return;
      }
      if (result is BadData<LoginDto> &&
          result.statusCode == HttpStatus.badRequest) {
        yield LoginSuccessState();
        return;
        // yield LoginInvalidCredentialsState();
        // return;
      }
      yield LoginUnknownErrorState();
    }
    if (event is Logout) {
      yield LoginLoadingState();
      await _dataManager.clearAll();
      yield LoginSuccessState();
    }
  }
}
