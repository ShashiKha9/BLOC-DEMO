import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import '../api/group_manage_contacts_api.dart';
import '../dto/group_manage_contacts_dto.dart';

abstract class GroupManageContactsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetManageContacts extends GroupManageContactsEvent {
  final String groupId;
  final String? filter;
  final String? branchId;

  GetManageContacts(this.groupId, this.filter, this.branchId);

  @override
  List<Object?> get props => [groupId];
}

abstract class ManageContactsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManageContactsInitialState extends ManageContactsState {}

class GroupManageContactsLoadingState extends ManageContactsInitialState {}

class GroupManageContactsNotFoundState extends ManageContactsInitialState {}

class GroupManageContactsErrorState extends ManageContactsInitialState {
  final String message;

  GroupManageContactsErrorState(this.message);
}

class GetManageContactsSuccessState extends ManageContactsState {
  final List<GroupManageContactBranchDto> manageContactsData;

  GetManageContactsSuccessState(this.manageContactsData);

  @override
  List<Object?> get props => [manageContactsData];
}

class GroupManageContactsBloc
    extends Bloc<GroupManageContactsEvent, ManageContactsState> {
  final IManageGroupContactsApi _api;
  GroupManageContactsBloc(this._api) : super(ManageContactsInitialState());

  @override
  Stream<ManageContactsState> mapEventToState(
      GroupManageContactsEvent event) async* {
    if (event is GetManageContacts) {
      yield GroupManageContactsLoadingState();
      var result = await _api.getGroupContactBranchIncidentDetails(
          event.groupId, event.filter ?? "", event.branchId ?? "");
      if (result is OkData<List<GroupManageContactBranchDto>>) {
        if (result.dto.isEmpty) {
          yield GroupManageContactsNotFoundState();
        }
        yield GetManageContactsSuccessState(result.dto);
        return;
      }

      if (result is BadData<List<GroupManageContactBranchDto>>) {
        yield GroupManageContactsErrorState(result.message);
        return;
      }
    }
  }
}
