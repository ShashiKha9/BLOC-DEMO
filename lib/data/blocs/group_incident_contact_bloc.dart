import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_contact_api.dart';
import 'package:rescu_organization_portal/data/api/group_info_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_contact_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_info_dto.dart';

abstract class GroupIncidentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupIncidentContacts extends GroupIncidentEvent {
  final String? groupId;
  final String? filter;

  GetGroupIncidentContacts(this.groupId, this.filter);

  @override
  List<Object?> get props => [groupId];
}

class DeleteGroupIncidentContact extends GroupIncidentEvent {
  final String groupId;
  final String contactId;

  DeleteGroupIncidentContact(this.groupId, this.contactId);

  @override
  List<Object> get props => [groupId, contactId];
}

class AddGroupIncidentContact extends GroupIncidentEvent {
  final String groupId;
  final GroupIncidentContactDto contact;

  AddGroupIncidentContact(this.groupId, this.contact);

  @override
  List<Object> get props => [groupId, contact];
}

class UpdateGroupIncidentContact extends GroupIncidentEvent {
  final String groupId;
  final String contactId;
  final GroupIncidentContactDto contact;

  UpdateGroupIncidentContact(this.groupId, this.contactId, this.contact);

  @override
  List<Object> get props => [groupId, contactId, contact];
}

abstract class GroupIncidentState extends Equatable {
  @override
  List<Object> get props => [];
}

class GroupIncidentInitialState extends GroupIncidentState {}

class GroupIncidentLoadingState extends GroupIncidentState {}

class GroupIncidentErrorState extends GroupIncidentState {}

class LoadGroupDetailsState extends GroupIncidentState {
  final GroupInfoDto groupInfo;

  LoadGroupDetailsState(this.groupInfo);

  @override
  List<Object> get props => [groupInfo];
}

class GetGroupIncidentContactsSuccessState extends GroupIncidentState {
  final List<GroupIncidentContactDto> contacts;

  GetGroupIncidentContactsSuccessState(this.contacts);

  @override
  List<Object> get props => [contacts];
}

class GetGroupIncidentContactsNotFoundState extends GroupIncidentState {}

class DeleteGroupIncidentContactSuccessState extends GroupIncidentState {}

class ContactAddedSuccessState extends GroupIncidentState {}

class ContactUpdatedSuccessState extends GroupIncidentState {}

class GroupIncidentContactBloc
    extends Bloc<GroupIncidentEvent, GroupIncidentState> {
  final IGroupInfoApi _groupInfoApi;
  final IGroupIncidentContactsApi _contactsApi;
  GroupIncidentContactBloc(this._groupInfoApi, this._contactsApi)
      : super(GroupIncidentInitialState());

  @override
  Stream<GroupIncidentState> mapEventToState(GroupIncidentEvent event) async* {
    if (event is GetGroupIncidentContacts) {
      yield GroupIncidentLoadingState();
      late String groupId;
      if (event.groupId == null) {
        var result = await _groupInfoApi.getLoggedInUserGroup();
        if (result is OkData<GroupInfoDto>) {
          yield LoadGroupDetailsState(result.dto);
          yield GroupIncidentLoadingState();
        } else {
          yield GroupIncidentErrorState();
          return;
        }
      } else {
        groupId = event.groupId!;
      }

      var result =
          await _contactsApi.getGroupIncidentContacts(groupId, event.filter);

      if (result is OkData<List<GroupIncidentContactDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetGroupIncidentContactsSuccessState(result.dto);
        } else {
          yield GetGroupIncidentContactsNotFoundState();
        }
        return;
      } else {
        yield GroupIncidentErrorState();
        return;
      }
    }

    if (event is DeleteGroupIncidentContact) {
      yield GroupIncidentLoadingState();
      var result = await _contactsApi.deleteGroupIncidentContact(
          event.groupId, event.contactId);
      if (result is Ok) {
        yield DeleteGroupIncidentContactSuccessState();
        return;
      } else {
        yield GroupIncidentErrorState();
        return;
      }
    }
  }
}

class AddUpdateGroupIncidentContactBloc
    extends Bloc<GroupIncidentEvent, GroupIncidentState> {
  final IGroupIncidentContactsApi _contactsApi;
  AddUpdateGroupIncidentContactBloc(this._contactsApi)
      : super(GroupIncidentInitialState());

  @override
  Stream<GroupIncidentState> mapEventToState(GroupIncidentEvent event) async* {
    if (event is AddGroupIncidentContact) {
      yield GroupIncidentLoadingState();

      var result = await _contactsApi.addGroupIncidentContact(
          event.groupId, event.contact);

      if (result is Ok) {
        yield ContactAddedSuccessState();
        return;
      } else {
        yield GroupIncidentErrorState();
        return;
      }
    }
    if (event is UpdateGroupIncidentContact) {
      yield GroupIncidentLoadingState();

      var result = await _contactsApi.updateGroupIncidentContact(
          event.groupId, event.contactId, event.contact);

      if (result is Ok) {
        yield ContactUpdatedSuccessState();
        return;
      } else {
        yield GroupIncidentErrorState();
        return;
      }
    }
  }
}
