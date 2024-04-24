import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rescu_organization_portal/data/api/authentication_api.dart';

import '../api/base_api.dart';

// Events
abstract class ResetPasswordEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetPasswordEvent extends ResetPasswordEvents {
  final String? id;
  final String? token;
  final String password;

  ResetPasswordEvent(this.id, this.token, this.password);

  @override
  List<Object?> get props => [id, token, password];
}

// States
abstract class ResetPasswordState extends Equatable {
  @override
  List<Object> get props => [];
}

class ResetPasswordInitialState extends ResetPasswordState {}

class ResetPasswordLoadingState extends ResetPasswordState {}

class ResetPasswordSuccessState extends ResetPasswordState {}

class ResetPasswordUnknownErrorState extends ResetPasswordState {}

class ResetPasswordNotConnectedState extends ResetPasswordState {}

class ResetPasswordInvalidFieldState extends ResetPasswordState {}

class ResetPasswordBloc extends Bloc<ResetPasswordEvents, ResetPasswordState> {
  final IAuthenticationApi _authenticationRepository;

  ResetPasswordBloc(this._authenticationRepository)
      : super(ResetPasswordInitialState());

  @override
  Stream<ResetPasswordState> mapEventToState(ResetPasswordEvents event) async* {
    if (event is ResetPasswordEvent) {
      yield ResetPasswordLoadingState();
      var result = await _authenticationRepository.resetPassword(
          event.id, event.token, event.password);
      if (result is Ok) {
        yield ResetPasswordSuccessState();
        yield ResetPasswordInitialState();
        return;
      } else if (result is Bad) {
        yield ResetPasswordInvalidFieldState();
        return;
      }
    }
  }
}
