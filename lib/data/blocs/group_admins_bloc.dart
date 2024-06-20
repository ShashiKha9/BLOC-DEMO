import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/base_api.dart';
import '../api/group_branch_api.dart';
import '../api/group_incident_type_api.dart';
import '../api/group_info_api.dart';
import '../api/group_invite_contact_api.dart';
import '../dto/group_branch_dto.dart';
import '../dto/group_incident_type_dto.dart';
import '../dto/group_info_dto.dart';
import '../dto/group_invite_contact_dto.dart';
import '../models/group_incident_type_model.dart';

abstract class GroupAdminsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupAdmins extends GroupAdminsEvent {
  final String? groupId;
  final String? filter;
  final String active;
  GetGroupAdmins(this.groupId, this.filter, this.active);

  @override
  List<Object?> get props => [groupId, filter];
}

class ActivateDeactivateGroupAdmin extends GroupAdminsEvent {
  final String groupId;
  final String inviteId;
  final GroupInviteContactDto contact;

  ActivateDeactivateGroupAdmin(this.groupId, this.inviteId, this.contact);

  @override
  List<Object> get props => [groupId, inviteId, contact];
}

class RefreshAdminList extends GroupAdminsEvent {}

class AddGroupAdmin extends GroupAdminsEvent {
  final String groupId;
  final GroupInviteContactDto contact;

  AddGroupAdmin(this.groupId, this.contact);

  @override
  List<Object> get props => [groupId, contact];
}

class UpdateGroupAdmin extends GroupAdminsEvent {
  final String groupId;
  final String inviteId;
  final GroupInviteContactDto contact;

  UpdateGroupAdmin(this.groupId, this.inviteId, this.contact);

  @override
  List<Object> get props => [groupId, inviteId, contact];
}

class GetIncidentTypes extends GroupAdminsEvent {
  final String? filter;

  GetIncidentTypes(this.filter);

  @override
  List<Object?> get props => [filter];
}

class GetBranches extends GroupAdminsEvent {
  final String groupId;

  GetBranches(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

abstract class GroupAdminsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupAdminsInitialState extends GroupAdminsState {}

class GroupAdminsLoadingState extends GroupAdminsState {}

class GroupAdminsErrorState extends GroupAdminsState {
  final String? error;

  GroupAdminsErrorState({this.error});

  @override
  List<Object?> get props => [error];
}

class LoadGroupDetailsState extends GroupAdminsState {
  final GroupInfoDto groupInfo;

  LoadGroupDetailsState(this.groupInfo);

  @override
  List<Object> get props => [groupInfo];
}

class GetGroupAdminsSuccessState extends GroupAdminsState {
  final List<GroupInviteContactDto> contacts;

  GetGroupAdminsSuccessState(this.contacts);

  @override
  List<Object> get props => [contacts];
}

class GetGroupAdminsNotFoundState extends GroupAdminsState {}

class ActivateDeActivateAdminSuccessState extends GroupAdminsState {}

class RefreshAdminListState extends GroupAdminsState {}

class AdminAddedSuccessState extends GroupAdminsState {}

class AdminUpdatedSuccessState extends GroupAdminsState {}

class GetIncidentTypeSuccessState extends GroupAdminsState {
  final List<GroupIncidentTypeModel> model;

  GetIncidentTypeSuccessState(this.model);

  @override
  List<Object?> get props => [model];
}

class GetBranchesSuccessState extends GroupAdminsState {
  final List<GroupBranchDto> branches;

  GetBranchesSuccessState(this.branches);

  @override
  List<Object?> get props => [branches];
}

class GroupAdminBloc extends Bloc<GroupAdminsEvent, GroupAdminsState> {
  final IGroupInfoApi _groupInfoApi;
  final IGroupInviteContactsApi _contactsApi;
  GroupAdminBloc(this._groupInfoApi, this._contactsApi)
      : super(GroupAdminsInitialState());

  @override
  Stream<GroupAdminsState> mapEventToState(GroupAdminsEvent event) async* {
    if (event is GetGroupAdmins) {
      yield GroupAdminsLoadingState();
      late String groupId;
      if (event.groupId == null) {
        var result = await _groupInfoApi.getLoggedInUserGroup();
        if (result is OkData<GroupInfoDto>) {
          yield LoadGroupDetailsState(result.dto);
          yield GroupAdminsLoadingState();
        } else {
          yield GroupAdminsErrorState();
          return;
        }
      } else {
        groupId = event.groupId!;
      }

      var result = await _contactsApi.getGroupAdmins(
          groupId, event.filter, event.active);

      if (result is OkData<List<GroupInviteContactDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetGroupAdminsSuccessState(result.dto);
        } else {
          yield GetGroupAdminsNotFoundState();
        }
        return;
      } else {
        yield GroupAdminsErrorState();
        return;
      }
    }

    if (event is ActivateDeactivateGroupAdmin) {
      yield GroupAdminsLoadingState();

      var result = await _contactsApi.updateGroupAdmin(
          event.groupId, event.inviteId, event.contact);

      if (result is Ok) {
        yield ActivateDeActivateAdminSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupAdminsErrorState(error: result.message);
        return;
      } else {
        yield GroupAdminsErrorState();
        return;
      }
    }

    if (event is RefreshAdminList) {
      yield GroupAdminsLoadingState();
      yield RefreshAdminListState();
      return;
    }
  }
}

class AddUpdateGroupAdminBloc
    extends Bloc<GroupAdminsEvent, GroupAdminsState> {
  final IGroupInviteContactsApi _contactsApi;
  final IGroupIncidentTypeApi _incidentTypeApi;
  final IGroupBranchApi _groupBranchApi;
  AddUpdateGroupAdminBloc(
      this._contactsApi, this._incidentTypeApi, this._groupBranchApi)
      : super(GroupAdminsInitialState());

  @override
  Stream<GroupAdminsState> mapEventToState(
      GroupAdminsEvent event) async* {
    if (event is AddGroupAdmin) {
      yield GroupAdminsLoadingState();

      var result = await _contactsApi.addGroupAdmin(
          event.groupId, event.contact);

      if (result is Ok) {
        yield AdminAddedSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupAdminsErrorState(error: result.message);
        return;
      } else {
        yield GroupAdminsErrorState();
        return;
      }
    }
    if (event is UpdateGroupAdmin) {
      yield GroupAdminsLoadingState();

      var result = await _contactsApi.updateGroupAdmin(
          event.groupId, event.inviteId, event.contact);

      if (result is Ok) {
        yield AdminUpdatedSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupAdminsErrorState(error: result.message);
        return;
      } else {
        yield GroupAdminsErrorState();
        return;
      }
    }
    if (event is GetIncidentTypes) {
      yield GroupAdminsLoadingState();

      var result = await _incidentTypeApi.get(event.filter ?? "", null);
      if (result is OkData<List<GroupIncidentTypeDto>>) {
        yield GetIncidentTypeSuccessState(
            result.dto.map((e) => GroupIncidentTypeModel.fromDto(e)).toList());
      } else if (result is BadData<List<GroupIncidentTypeDto>>) {
        yield GroupAdminsErrorState(error: result.message);
      } else {
        yield GroupAdminsErrorState();
      }
    }
    if (event is GetBranches) {
      yield GroupAdminsLoadingState();

      var result = await _groupBranchApi.getGroupBranches(event.groupId, "");
      if (result is OkData<List<GroupBranchDto>>) {
        yield GetBranchesSuccessState(result.dto);
      } else if (result is BadData<List<GroupBranchDto>>) {
        yield GroupAdminsErrorState(error: result.message);
      } else {
        yield GroupAdminsErrorState();
      }
    }
  }
}
