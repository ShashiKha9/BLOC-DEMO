import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';

abstract class GroupIncidentTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetIncidentTypes extends GroupIncidentTypeEvent {
  final String groupId;
  final String filter;

  GetIncidentTypes(this.groupId, this.filter);

  @override
  List<Object?> get props => [groupId, filter];
}

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

abstract class GroupIncidentTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupIncidentTypeInitialState extends GroupIncidentTypeState {}

class GroupIncidentTypeLoadingState extends GroupIncidentTypeState {}

class GroupIncidentTypeFailedState extends GroupIncidentTypeState {
  final String? message;

  GroupIncidentTypeFailedState({this.message});

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

class GroupIncidentTypeBloc
    extends Bloc<GroupIncidentTypeEvent, GroupIncidentTypeState> {
  final IGroupIncidentTypeApi _api;
  GroupIncidentTypeBloc(this._api) : super(GroupIncidentTypeInitialState());

  @override
  Stream<GroupIncidentTypeState> mapEventToState(
      GroupIncidentTypeEvent event) async* {
    if (event is GetIncidentTypes) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.get(event.filter);

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
    if (event is AddIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.add(event.groupId, event.model.toDto());
      if (result is Ok) {
        yield AddGroupIncidentTypeSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeFailedState();
      }
    }

    if (event is UpdateIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.update(
          event.groupId, event.incidentTypeId, event.model.toDto());
      if (result is Ok) {
        yield UpdateGroupIncidentTypeSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeFailedState();
      }
    }

    if (event is DeleteIncidentType) {
      yield GroupIncidentTypeLoadingState();

      var result = await _api.delete(event.id, event.incidentId);
      if (result is Ok) {
        yield DeleteGroupIncidentTypeSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeFailedState();
      }
    }
  }
}
