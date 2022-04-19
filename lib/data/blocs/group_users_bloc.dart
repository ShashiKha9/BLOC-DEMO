import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_user_api.dart';
import 'package:rescu_organization_portal/data/dto/group_user_dto.dart';
import 'package:rescu_organization_portal/data/models/group_user_model.dart';

// Events
abstract class GroupUserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetGroupUsers extends GroupUserEvent {
  final String searchValue;

  GetGroupUsers(this.searchValue);

  @override
  List<Object> get props => [searchValue];
}

class GetGroupUser extends GroupUserEvent {
  final String id;

  GetGroupUser(this.id);

  @override
  List<Object> get props => [id];
}

class ViewGroupUserDetails extends GroupUserEvent {
  final String userId;

  ViewGroupUserDetails(this.userId);

  @override
  List<Object> get props => [userId];
}

class DeleteGroupUser extends GroupUserEvent {
  final String userId;

  DeleteGroupUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddGroupUser extends GroupUserEvent {
  final List<String> emails;

  AddGroupUser(this.emails);

  @override
  List<Object> get props => [emails];
}

class UpdateGroupUser extends GroupUserEvent {
  final GroupUserModel groupUser;

  UpdateGroupUser(this.groupUser);

  @override
  List<Object> get props => [groupUser];
}

// States
abstract class GroupUserState extends Equatable {
  @override
  List<Object> get props => [];
}

class GroupUserInitialState extends GroupUserState {}

class GroupUserLoadingState extends GroupUserState {}

class GroupUserUnknownErrorState extends GroupUserState {}

class GetGroupUsersSuccessState extends GroupUserState {
  final List<GroupUserModel> groupUsers;

  GetGroupUsersSuccessState(this.groupUsers);

  @override
  List<Object> get props => [groupUsers];
}

class GetGroupUserSuccessState extends GroupUserState {
  final GroupUserModel groupUser;
  GetGroupUserSuccessState(this.groupUser);

  @override
  List<Object> get props => [groupUser];
}

class GetGroupUsersNotFoundState extends GroupUserState {}

class GetGroupUserNotFoundState extends GroupUserState {}

class GetGroupUsersErrorState extends GroupUserState {}

class GetGroupUserErrorState extends GroupUserState {
  final String errorMessage;
  GetGroupUserErrorState(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class UpdateGroupUserSuccessState extends GroupUserState {}

class UpdateGroupUserErrorState extends GroupUserState {
  final String errorMessage;
  UpdateGroupUserErrorState(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class DeleteGroupUserErrorState extends GroupUserState {}

class DeleteGroupUserSuccessState extends GroupUserState {}

class ResetPasswordSuccessState extends GroupUserState {}

class ResetPasswordErrorState extends GroupUserState {}

class AddGroupUserSuccessState extends GroupUserState {}

class AddGroupUserErrorState extends GroupUserState {
  final String message;

  AddGroupUserErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class GroupUserBloc extends Bloc<GroupUserEvent, GroupUserState> {
  final IGroupUserApi _groupUserApi;
  GroupUserBloc(this._groupUserApi) : super(GroupUserInitialState());

  @override
  Stream<GroupUserState> mapEventToState(GroupUserEvent event) async* {
    if (event is GetGroupUsers) {
      yield GroupUserLoadingState();
      var result = await _groupUserApi.getGroupUsers(event.searchValue);
      if (result is OkData<List<GroupUserDto>>) {
        yield GetGroupUsersSuccessState(
            result.dto.map((e) => GroupUserModel.fromDto(e)).toList());
        return;
      } else if (result is BadData<List<GroupUserDto>>) {
        yield GetGroupUsersNotFoundState();
        return;
      }
      yield GetGroupUsersErrorState();
    }
    if (event is UpdateGroupUser) {
      yield GroupUserLoadingState();

      var result = await _groupUserApi.updateGroupUser(
          event.groupUser.toDto(), event.groupUser.id);

      if (result is Ok) {
        yield UpdateGroupUserSuccessState();
        return;
      }
      if (result is Bad) {
        yield UpdateGroupUserErrorState(result.message);
      }
    }
  }
}

class AddGroupUserBloc extends Bloc<GroupUserEvent, GroupUserState> {
  final IGroupUserApi _groupUserApi;
  AddGroupUserBloc(this._groupUserApi) : super(GroupUserInitialState());

  @override
  Stream<GroupUserState> mapEventToState(GroupUserEvent event) async* {
    if (event is AddGroupUser) {
      yield GroupUserLoadingState();
      var result = await _groupUserApi.addGroupUser(event.emails);
      if (result is Ok) {
        yield AddGroupUserSuccessState();
        return;
      } else if (result is Bad) {
        yield AddGroupUserErrorState(result.message);
        return;
      }
    }
  }
}

class ViewGroupUserBloc extends Bloc<GroupUserEvent, GroupUserState> {
  final IGroupUserApi _groupUserApi;
  ViewGroupUserBloc(this._groupUserApi) : super(GroupUserInitialState());

  @override
  Stream<GroupUserState> mapEventToState(GroupUserEvent event) async* {
    if (event is GetGroupUser) {
      yield GroupUserLoadingState();
      var result = await _groupUserApi.getGroupUser(event.id);
      if (result is OkData<GroupUserDto>) {
        yield GetGroupUserSuccessState(GroupUserModel.fromDto(result.dto));
        return;
      } else if (result is BadData<GroupUserDto>) {
        yield GetGroupUserErrorState(result.message);
        return;
      }
    }
  }
}
