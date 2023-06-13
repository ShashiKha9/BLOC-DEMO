import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/api/group_info_api.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_info_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';

import '../api/group_invite_contact_api.dart';
import '../dto/group_invite_contact_dto.dart';

abstract class GroupInviteContactEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupInviteContacts extends GroupInviteContactEvent {
  final String? groupId;
  final String? filter;
  final String role;
  GetGroupInviteContacts(this.groupId, this.filter, this.role);

  @override
  List<Object?> get props => [groupId, filter, role];
}

class GetIncidentTypes extends GroupInviteContactEvent {
  final String? filter;

  GetIncidentTypes(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeleteGroupInviteContact extends GroupInviteContactEvent {
  final String groupId;
  final String inviteId;

  DeleteGroupInviteContact(this.groupId, this.inviteId);

  @override
  List<Object> get props => [groupId, inviteId];
}

class AddGroupInviteContact extends GroupInviteContactEvent {
  final String groupId;
  final GroupInviteContactDto contact;

  AddGroupInviteContact(this.groupId, this.contact);

  @override
  List<Object> get props => [groupId, contact];
}

class UpdateGroupInviteContact extends GroupInviteContactEvent {
  final String groupId;
  final String inviteId;
  final GroupInviteContactDto contact;

  UpdateGroupInviteContact(this.groupId, this.inviteId, this.contact);

  @override
  List<Object> get props => [groupId, inviteId, contact];
}

class ActivateDeactivateGroupInviteContact extends GroupInviteContactEvent {
  final String groupId;
  final String inviteId;
  final GroupInviteContactDto contact;

  ActivateDeactivateGroupInviteContact(
      this.groupId, this.inviteId, this.contact);

  @override
  List<Object> get props => [groupId, inviteId, contact];
}

abstract class GroupInviteContactState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInviteContactInitialState extends GroupInviteContactState {}

class GroupInviteContactLoadingState extends GroupInviteContactState {}

class GroupInviteContactErrorState extends GroupInviteContactState {
  final String? error;

  GroupInviteContactErrorState({this.error});

  @override
  List<Object?> get props => [error];
}

class LoadGroupDetailsState extends GroupInviteContactState {
  final GroupInfoDto groupInfo;

  LoadGroupDetailsState(this.groupInfo);

  @override
  List<Object> get props => [groupInfo];
}

class GetGroupInviteContactsSuccessState extends GroupInviteContactState {
  final List<GroupInviteContactDto> contacts;

  GetGroupInviteContactsSuccessState(this.contacts);

  @override
  List<Object> get props => [contacts];
}

class GetGroupInviteContactsNotFoundState extends GroupInviteContactState {}

class DeleteGroupInviteContactSuccessState extends GroupInviteContactState {}

class ActivateDeActivateContactSuccessState extends GroupInviteContactState {}

class ContactAddedSuccessState extends GroupInviteContactState {}

class ContactUpdatedSuccessState extends GroupInviteContactState {}

class GetIncidentTypeSuccessState extends GroupInviteContactState {
  final List<GroupIncidentTypeModel> model;

  GetIncidentTypeSuccessState(this.model);

  @override
  List<Object?> get props => [model];
}

class GroupInviteContactBloc
    extends Bloc<GroupInviteContactEvent, GroupInviteContactState> {
  final IGroupInfoApi _groupInfoApi;
  final IGroupInviteContactsApi _contactsApi;
  GroupInviteContactBloc(this._groupInfoApi, this._contactsApi)
      : super(GroupInviteContactInitialState());

  @override
  Stream<GroupInviteContactState> mapEventToState(
      GroupInviteContactEvent event) async* {
    if (event is GetGroupInviteContacts) {
      yield GroupInviteContactLoadingState();
      late String groupId;
      if (event.groupId == null) {
        var result = await _groupInfoApi.getLoggedInUserGroup();
        if (result is OkData<GroupInfoDto>) {
          yield LoadGroupDetailsState(result.dto);
          yield GroupInviteContactLoadingState();
        } else {
          yield GroupInviteContactErrorState();
          return;
        }
      } else {
        groupId = event.groupId!;
      }

      var result = await _contactsApi.getGroupInviteContacts(
          groupId, event.filter, event.role);

      if (result is OkData<List<GroupInviteContactDto>>) {
        if (event.role == FleetUserRoles.contact) {
          var adminResult = await _contactsApi.getGroupInviteContacts(
              event.groupId!, event.filter, FleetUserRoles.admin);
          if (adminResult is OkData<List<GroupInviteContactDto>> &&
              adminResult.dto.isNotEmpty) {
            result.dto.add(adminResult.dto.first);
          }
        }
        if (result.dto.isNotEmpty) {
          yield GetGroupInviteContactsSuccessState(result.dto);
        } else {
          yield GetGroupInviteContactsNotFoundState();
        }
        return;
      } else {
        yield GroupInviteContactErrorState();
        return;
      }
    }

    if (event is DeleteGroupInviteContact) {
      yield GroupInviteContactLoadingState();
      var result = await _contactsApi.deleteGroupInviteContact(
          event.groupId, event.inviteId);
      if (result is Ok) {
        yield DeleteGroupInviteContactSuccessState();
        return;
      } else {
        yield GroupInviteContactErrorState();
        return;
      }
    }
    if (event is ActivateDeactivateGroupInviteContact) {
      yield GroupInviteContactLoadingState();

      var result = await _contactsApi.updateGroupInviteContact(
          event.groupId, event.inviteId, event.contact);

      if (result is Ok) {
        yield ActivateDeActivateContactSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupInviteContactErrorState(error: result.message);
        return;
      } else {
        yield GroupInviteContactErrorState();
        return;
      }
    }
  }
}

class AddUpdateGroupInviteContactBloc
    extends Bloc<GroupInviteContactEvent, GroupInviteContactState> {
  final IGroupInviteContactsApi _contactsApi;
  final IGroupIncidentTypeApi _incidentTypeApi;
  AddUpdateGroupInviteContactBloc(this._contactsApi, this._incidentTypeApi)
      : super(GroupInviteContactInitialState());

  @override
  Stream<GroupInviteContactState> mapEventToState(
      GroupInviteContactEvent event) async* {
    if (event is AddGroupInviteContact) {
      yield GroupInviteContactLoadingState();

      var result = await _contactsApi.addGroupInviteContact(
          event.groupId, event.contact);

      if (result is Ok) {
        yield ContactAddedSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupInviteContactErrorState(error: result.message);
        return;
      } else {
        yield GroupInviteContactErrorState();
        return;
      }
    }
    if (event is UpdateGroupInviteContact) {
      yield GroupInviteContactLoadingState();

      var result = await _contactsApi.updateGroupInviteContact(
          event.groupId, event.inviteId, event.contact);

      if (result is Ok) {
        yield ContactUpdatedSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupInviteContactErrorState(error: result.message);
        return;
      } else {
        yield GroupInviteContactErrorState();
        return;
      }
    }
    if (event is GetIncidentTypes) {
      yield GroupInviteContactLoadingState();

      var result = await _incidentTypeApi.get(event.filter ?? "");
      if (result is OkData<List<GroupIncidentTypeDto>>) {
        yield GetIncidentTypeSuccessState(
            result.dto.map((e) => GroupIncidentTypeModel.fromDto(e)).toList());
      } else if (result is BadData<List<GroupIncidentTypeDto>>) {
        yield GroupInviteContactErrorState(error: result.message);
      } else {
        yield GroupInviteContactErrorState();
      }
    }
  }
}
