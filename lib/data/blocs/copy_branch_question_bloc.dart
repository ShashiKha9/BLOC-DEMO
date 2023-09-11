import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_question_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';

abstract class CopyBranchQuestionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetBranches extends CopyBranchQuestionEvent {
  final String groupId;

  GetBranches(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GetIncidentTypes extends CopyBranchQuestionEvent {
  final String branchId;

  GetIncidentTypes(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class GetBranchQuestions extends CopyBranchQuestionEvent {
  final String groupId;
  final String branchId;

  GetBranchQuestions(this.groupId, this.branchId);

  @override
  List<Object?> get props => [groupId, branchId];
}

class CopyBranchQuestion extends CopyBranchQuestionEvent {
  final String groupId;
  final String branchId;
  final String incidentTypeId;
  final List<GroupIncidentTypeQuestionDto> questions;

  CopyBranchQuestion(
      this.groupId, this.branchId, this.incidentTypeId, this.questions);

  @override
  List<Object?> get props => [groupId, branchId, incidentTypeId, questions];
}

abstract class CopyBranchQuestionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CopyBranchQuestionInitial extends CopyBranchQuestionState {}

class CopyBranchQuestionLoading extends CopyBranchQuestionState {}

class CopyBranchQuestionSuccess extends CopyBranchQuestionState {}

class CopyBranchQuestionFailure extends CopyBranchQuestionState {
  final String error;

  CopyBranchQuestionFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CopyBranchQuestionLoaded extends CopyBranchQuestionState {
  final List<GroupIncidentTypeQuestionDto> questions;

  CopyBranchQuestionLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class CopyBranchQuestionBranchesLoaded extends CopyBranchQuestionState {
  final List<GroupBranchDto> branches;

  CopyBranchQuestionBranchesLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class IncidentTypeLoadedState extends CopyBranchQuestionState {
  final List<GroupIncidentTypeDto> incidentTypes;

  IncidentTypeLoadedState(this.incidentTypes);

  @override
  List<Object?> get props => [incidentTypes];
}

class CopyBranchQuestionBloc
    extends Bloc<CopyBranchQuestionEvent, CopyBranchQuestionState> {
  final IGroupBranchApi _branchApi;
  final IGroupIncidentTypeQuestionApi _groupIncidentTypeQuestionApi;
  final IGroupIncidentTypeApi _groupIncidentTypeApi;

  CopyBranchQuestionBloc(this._branchApi, this._groupIncidentTypeQuestionApi,
      this._groupIncidentTypeApi)
      : super(CopyBranchQuestionInitial());

  @override
  Stream<CopyBranchQuestionState> mapEventToState(
      CopyBranchQuestionEvent event) async* {
    if (event is GetBranches) {
      yield CopyBranchQuestionLoading();
      try {
        final branches = await _branchApi.getGroupBranches(event.groupId, "");
        if (branches is OkData<List<GroupBranchDto>>) {
          yield CopyBranchQuestionBranchesLoaded(branches.dto);
        }
      } catch (e) {
        yield CopyBranchQuestionFailure(e.toString());
      }
    } else if (event is GetBranchQuestions) {
      yield CopyBranchQuestionLoading();
      try {
        final questions = await _groupIncidentTypeQuestionApi.get(
            event.groupId, "", event.branchId);

        if (questions is OkData<List<GroupIncidentTypeQuestionDto>>) {
          yield CopyBranchQuestionLoaded(questions.dto);
        }
      } catch (e) {
        yield CopyBranchQuestionFailure(e.toString());
      }
    } else if (event is CopyBranchQuestion) {
      yield CopyBranchQuestionLoading();
      try {
        await _groupIncidentTypeQuestionApi.copy(event.groupId, event.branchId,
            event.incidentTypeId, event.questions.map((e) => e.id!).toList());
        yield CopyBranchQuestionSuccess();
      } catch (e) {
        yield CopyBranchQuestionFailure(e.toString());
      }
    }

    if (event is GetIncidentTypes) {
      yield CopyBranchQuestionLoading();
      try {
        final incidentTypes =
            await _groupIncidentTypeApi.get("", event.branchId);
        if (incidentTypes is OkData<List<GroupIncidentTypeDto>>) {
          yield IncidentTypeLoadedState(incidentTypes.dto);
        }
      } catch (e) {
        yield CopyBranchQuestionFailure(e.toString());
      }
    }
  }
}
