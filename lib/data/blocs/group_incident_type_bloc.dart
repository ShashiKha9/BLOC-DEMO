import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';

abstract class GroupIncidentTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetIncidentTypes extends GroupIncidentTypeEvent {
  final String filter;
  final String? branchId;

  GetIncidentTypes(this.filter, this.branchId);

  @override
  List<Object?> get props => [filter, branchId];
}

class ClickedFabIconEvent extends GroupIncidentTypeEvent {}

class AddIncidentType extends GroupIncidentTypeEvent {
  final String groupId;
  final GroupIncidentTypeModel model;

  AddIncidentType(this.groupId, this.model);

  @override
  List<Object?> get props => [groupId, model];
}

class UpdateIncidentType extends GroupIncidentTypeEvent {
  final String groupId;
  final String incidentTypeId;
  final GroupIncidentTypeModel model;

  UpdateIncidentType(this.groupId, this.incidentTypeId, this.model);

  @override
  List<Object?> get props => [groupId, incidentTypeId, model];
}

class DeleteIncidentType extends GroupIncidentTypeEvent {
  final String id;
  final String incidentId;

  DeleteIncidentType(this.id, this.incidentId);

  @override
  List<Object?> get props => [id, incidentId];
}

class GetBranches extends GroupIncidentTypeEvent {
  final String groupId;
  final String filter;

  GetBranches(this.groupId, this.filter);

  @override
  List<Object?> get props => [groupId, filter];
}

class BranchChangedEvent extends GroupIncidentTypeEvent {
  final String? branchId;

  BranchChangedEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class RefreshIncidentTypes extends GroupIncidentTypeEvent {}

class GetIncidentTypesTotalCount extends GroupIncidentTypeEvent {
  final String? branchId;

  GetIncidentTypesTotalCount(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

abstract class GroupIncidentTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupIncidentTypeInitialState extends GroupIncidentTypeState {}

class GroupIncidentTypeLoadingState extends GroupIncidentTypeState {}

class ClickedFabIconState extends GroupIncidentTypeState {}

class GroupIncidentTypeFailedState extends GroupIncidentTypeState {
  final String? message;

  GroupIncidentTypeFailedState({this.message});

  @override
  List<Object?> get props => [message];
}

class AddUpdateGroupIncidentTypeFailedState extends GroupIncidentTypeState {
  final String? message;

  AddUpdateGroupIncidentTypeFailedState({this.message});

  @override
  List<Object?> get props => [message];
}

class GetGroupIncidentTypesNotFoundState extends GroupIncidentTypeState {}

class GetGroupIncidentTypesSuccessState extends GroupIncidentTypeState {
  final List<GroupIncidentTypeModel> model;

  GetGroupIncidentTypesSuccessState(this.model);

  @override
  List<Object?> get props => [model];
}

class AddGroupIncidentTypeSuccessState extends GroupIncidentTypeState {}

class UpdateGroupIncidentTypeSuccessState extends GroupIncidentTypeState {}

class DeleteGroupIncidentTypeSuccessState extends GroupIncidentTypeState {}

class GetBranchesSuccessState extends GroupIncidentTypeState {
  final List<GroupBranchDto> model;

  GetBranchesSuccessState(this.model);

  @override
  List<Object?> get props => [model];
}

class BranchChangedState extends GroupIncidentTypeState {
  final String? branchId;

  BranchChangedState(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class RefreshIncidentTypesState extends GroupIncidentTypeState {}

class IncidentTypeCountLoaded extends GroupIncidentTypeState {
  final int count;

  IncidentTypeCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

class GroupIncidentTypeBloc
    extends Bloc<GroupIncidentTypeEvent, GroupIncidentTypeState> {
  final IGroupIncidentTypeApi _api;
  final IGroupBranchApi _branchApi;
  GroupIncidentTypeBloc(this._api, this._branchApi)
      : super(GroupIncidentTypeInitialState());

  @override
  Stream<GroupIncidentTypeState> mapEventToState(
      GroupIncidentTypeEvent event) async* {
    if (event is ClickedFabIconEvent) {
      yield GroupIncidentTypeLoadingState();
      yield ClickedFabIconState();
      return;
    }

    if (event is GetIncidentTypes) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.get(event.filter, event.branchId);

      if (result is OkData<List<GroupIncidentTypeDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetGroupIncidentTypesSuccessState(result.dto
              .map((e) => GroupIncidentTypeModel.fromDto(e))
              .toList());
          return;
        } else {
          yield GetGroupIncidentTypesNotFoundState();
          return;
        }
      }
      if (result is BadData<List<GroupIncidentTypeDto>>) {
        yield GroupIncidentTypeFailedState(message: result.message);
        return;
      }
    }

    if (event is GetIncidentTypesTotalCount) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.get('', event.branchId);

      if (result is OkData<List<GroupIncidentTypeDto>>) {
        if (result.dto.isNotEmpty) {
          yield IncidentTypeCountLoaded(result.dto.length);
          return;
        } else {
          yield IncidentTypeCountLoaded(0);
          return;
        }
      }
      if (result is BadData<List<GroupIncidentTypeDto>>) {
        yield GroupIncidentTypeFailedState(message: result.message);
        return;
      }
    }

    if (event is AddIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.add(event.groupId, event.model.toDto());
      if (result is Ok) {
        yield AddGroupIncidentTypeSuccessState();
        return;
      } else if (result is Bad) {
        yield AddUpdateGroupIncidentTypeFailedState(message: result.message);
        return;
      } else {
        yield AddUpdateGroupIncidentTypeFailedState();
        return;
      }
    }

    if (event is UpdateIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.update(
          event.groupId, event.incidentTypeId, event.model.toDto());
      if (result is Ok) {
        yield UpdateGroupIncidentTypeSuccessState();
        return;
      } else if (result is Bad) {
        yield AddUpdateGroupIncidentTypeFailedState(message: result.message);
        return;
      } else {
        yield AddUpdateGroupIncidentTypeFailedState();
        return;
      }
    }

    if (event is DeleteIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.delete(event.id, event.incidentId);
      if (result is Ok) {
        yield DeleteGroupIncidentTypeSuccessState();
        return;
      } else if (result is Bad) {
        yield GroupIncidentTypeFailedState(message: result.message);
        return;
      } else {
        yield GroupIncidentTypeFailedState();
        return;
      }
    }

    if (event is GetBranches) {
      yield GroupIncidentTypeLoadingState();

      var result =
          await _branchApi.getGroupBranches(event.groupId, event.filter);

      if (result is OkData<List<GroupBranchDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetBranchesSuccessState(result.dto);
          return;
        } else {
          yield AddUpdateGroupIncidentTypeFailedState(
              message: "No branches found");
          return;
        }
      }
      if (result is BadData<List<GroupBranchDto>>) {
        yield AddUpdateGroupIncidentTypeFailedState(message: result.message);
        return;
      }
    }

    if (event is BranchChangedEvent) {
      yield BranchChangedState(event.branchId);
      return;
    }

    if (event is RefreshIncidentTypes) {
      yield RefreshIncidentTypesState();
      return;
    }
  }
}
