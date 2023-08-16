import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';

abstract class CopyIncidentTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetBranches extends CopyIncidentTypeEvent {
  final String groupId;

  GetBranches(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GetBranchIncidentTypes extends CopyIncidentTypeEvent {
  final String groupId;
  final String? branchId;

  GetBranchIncidentTypes(this.groupId, this.branchId);

  @override
  List<Object?> get props => [groupId, branchId];
}

class SaveIncidentTypes extends CopyIncidentTypeEvent {
  final String groupId;
  final String branchId;
  final List<GroupIncidentTypeDto> incidentTypes;

  SaveIncidentTypes(this.groupId, this.branchId, this.incidentTypes);

  @override
  List<Object?> get props => [groupId, branchId, incidentTypes];
}

abstract class CopyIncidentTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CopyIncidentTypeInitial extends CopyIncidentTypeState {}

class CopyIncidentTypeLoading extends CopyIncidentTypeState {}

class GetBranchesSuccessState extends CopyIncidentTypeState {
  final List<GroupBranchDto> branches;

  GetBranchesSuccessState(this.branches);

  @override
  List<Object?> get props => [branches];
}

class GetBranchIncidentTypesSuccessState extends CopyIncidentTypeState {
  final List<GroupIncidentTypeDto> incidentTypes;

  GetBranchIncidentTypesSuccessState(this.incidentTypes);

  @override
  List<Object?> get props => [incidentTypes];
}

class SaveIncidentTypesSuccessState extends CopyIncidentTypeState {}

class CopyBranchIncidentTypeBloc
    extends Bloc<CopyIncidentTypeEvent, CopyIncidentTypeState> {
  final IGroupBranchApi _branchApi;
  final IGroupIncidentTypeApi _incidentTypeApi;

  CopyBranchIncidentTypeBloc(this._branchApi, this._incidentTypeApi)
      : super(CopyIncidentTypeInitial());

  @override
  Stream<CopyIncidentTypeState> mapEventToState(
      CopyIncidentTypeEvent event) async* {
    if (event is GetBranches) {
      yield CopyIncidentTypeLoading();
      try {
        final branches = await _branchApi.getGroupBranches(event.groupId, '');
        if (branches is OkData<List<GroupBranchDto>>) {
          yield GetBranchesSuccessState(branches.dto);
        }
      } catch (e) {
        yield CopyIncidentTypeInitial();
      }
    }
    if (event is GetBranchIncidentTypes) {
      yield CopyIncidentTypeLoading();
      try {
        final incidentTypes = await _incidentTypeApi.get('', event.branchId);

        if (incidentTypes is OkData<List<GroupIncidentTypeDto>>) {
          yield GetBranchIncidentTypesSuccessState(incidentTypes.dto);
        }
      } catch (e) {
        yield CopyIncidentTypeInitial();
      }
    }
    if (event is SaveIncidentTypes) {
      yield CopyIncidentTypeLoading();
      for (var item in event.incidentTypes) {
        item.branches = [event.branchId];
        await _incidentTypeApi.add(event.groupId, item);
      }
      yield SaveIncidentTypesSuccessState();
    }
  }
}
