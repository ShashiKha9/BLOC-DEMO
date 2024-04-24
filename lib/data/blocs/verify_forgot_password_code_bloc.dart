import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';

import '../dto/password_reset_token_dto.dart';

abstract class VerifyForgotPasswordCodeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class VerifyForgotPasswordCodeSubmit extends VerifyForgotPasswordCodeEvent {
  final String code;
  final String token;

  VerifyForgotPasswordCodeSubmit(this.code, this.token);

  @override
  List<Object> get props => [code, token];
}

abstract class VerifyForgotPasswordCodeState extends Equatable {
  @override
  List<Object> get props => [];
}

class VerifyForgotPasswordCodeInitialState
    extends VerifyForgotPasswordCodeState {}

class VerifyForgotPasswordCodeLoadingState
    extends VerifyForgotPasswordCodeState {}

class VerifyForgotPasswordCodeSuccessState
    extends VerifyForgotPasswordCodeState {
  final String token;
  final String id;

  VerifyForgotPasswordCodeSuccessState(this.token, this.id);
}

class VerifyForgotPasswordCodeNotConnectedState
    extends VerifyForgotPasswordCodeState {}

class InvalidCodeState extends VerifyForgotPasswordCodeState {}

class TokenExpiredState extends VerifyForgotPasswordCodeState {}

class VerifyForgotPasswordCodeBloc
    extends Bloc<VerifyForgotPasswordCodeEvent, VerifyForgotPasswordCodeState> {
  final IAuthenticationApi _authenticationRepository;

  VerifyForgotPasswordCodeBloc(this._authenticationRepository)
      : super(VerifyForgotPasswordCodeInitialState());

  @override
  Stream<VerifyForgotPasswordCodeState> mapEventToState(
      VerifyForgotPasswordCodeEvent event) async* {
    if (event is VerifyForgotPasswordCodeSubmit) {
      yield VerifyForgotPasswordCodeLoadingState();
      var result = await _authenticationRepository.verifyPasswordResetCode(
          event.code, event.token);
      if (result is OkData<PasswordResetTokenDto>) {
        yield VerifyForgotPasswordCodeSuccessState(
            result.dto.token, result.dto.id);
      }
      if (result is BadData<PasswordResetTokenDto>) {
        if (result.statusCode == 401) {
          yield TokenExpiredState();
        } else {
          yield InvalidCodeState();
        }
      }
      yield VerifyForgotPasswordCodeInitialState();
      return;
    }
    throw UnimplementedError();
  }
}
