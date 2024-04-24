import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';

import '../api/authentication_api.dart';

abstract class ForgotPasswordEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ForgotPasswordSubmit extends ForgotPasswordEvent {
  final String emailAddress;

  ForgotPasswordSubmit(this.emailAddress);

  @override
  List<Object> get props => [emailAddress];
}

abstract class ForgotPasswordState extends Equatable {
  @override
  List<Object> get props => [];
}

class ForgotPasswordInitialState extends ForgotPasswordState {}

class ForgotPasswordLoadingState extends ForgotPasswordState {}

class ForgotPasswordSuccessState extends ForgotPasswordState {
  final String token;

  ForgotPasswordSuccessState(this.token);
}

class ForgotPasswordErrorState extends ForgotPasswordState {
  final String message;

  ForgotPasswordErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordNotConnectedState extends ForgotPasswordState {}

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final IAuthenticationApi _authenticationRepository;

  ForgotPasswordBloc(this._authenticationRepository)
      : super(ForgotPasswordInitialState());

  @override
  Stream<ForgotPasswordState> mapEventToState(
      ForgotPasswordEvent event) async* {
    if (event is ForgotPasswordSubmit) {
      yield ForgotPasswordLoadingState();
      var result =
          await _authenticationRepository.forgotPassword(event.emailAddress);
      if (result is BadData<String>) {
        if (result.statusCode == HttpStatus.notFound) {
          yield ForgotPasswordErrorState(
              "No account found matching the supplied email address. Please check your inputs and try again.");
        } else {
          yield ForgotPasswordErrorState(
              "An unexpected error occurred while attempting to reset your password. Please try again.");
        }
      }
      if (result is OkData<String>) {
        yield ForgotPasswordSuccessState(result.dto);
        yield ForgotPasswordInitialState();
      }
      return;
    }
  }
}
