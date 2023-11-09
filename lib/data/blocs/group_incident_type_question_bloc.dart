import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_api.dart';
import 'package:rescu_organization_portal/data/api/group_incident_type_question_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';

abstract class GroupIncidentTypeQuestionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetQuestions extends GroupIncidentTypeQuestionEvent {
  final String groupId;
  final String filter;
  final String? branchId;
  final String? incidentTypeId;

  GetQuestions(this.groupId, this.filter, this.branchId, this.incidentTypeId);

  @override
  List<Object?> get props => [groupId, filter, branchId];
}

class GetIncidents extends GroupIncidentTypeQuestionEvent {
  final String groupId;

  GetIncidents(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class AddQuestion extends GroupIncidentTypeQuestionEvent {
  final String groupId;
  final GroupIncidentTypeQuestionDto dto;

  AddQuestion(this.groupId, this.dto);

  @override
  List<Object?> get props => [groupId, dto];
}

class UpdateQuestion extends GroupIncidentTypeQuestionEvent {
  final String groupId;
  final String incidentTypeId;
  final GroupIncidentTypeQuestionDto dto;

  UpdateQuestion(this.groupId, this.incidentTypeId, this.dto);

  @override
  List<Object?> get props => [groupId, incidentTypeId, dto];
}

class DeleteQuestion extends GroupIncidentTypeQuestionEvent {
  final String id;
  final String questionId;

  DeleteQuestion(this.id, this.questionId);

  @override
  List<Object?> get props => [id, questionId];
}

class GetQuestion extends GroupIncidentTypeQuestionEvent {
  final String id;

  GetQuestion(this.id);

  @override
  List<Object?> get props => [id];
}

class GetBranches extends GroupIncidentTypeQuestionEvent {
  final String groupId;

  GetBranches(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class BranchChangedEvent extends GroupIncidentTypeQuestionEvent {
  final String? branchId;

  BranchChangedEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

// This is just a dummy event to refresh the questions
class RefreshQuestions extends GroupIncidentTypeQuestionEvent {}

class ChangeQuestionOrder extends GroupIncidentTypeQuestionEvent {
  final String incidentTypeId;
  final String questionId;
  final String order;

  ChangeQuestionOrder(this.incidentTypeId, this.questionId, this.order);

  @override
  List<Object> get props => [incidentTypeId, questionId, order];
}

abstract class GroupIncidentTypeQuestionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupIncidentTypeQuestionInitialState
    extends GroupIncidentTypeQuestionState {}

class GroupIncidentTypeQuestionLoadingState
    extends GroupIncidentTypeQuestionState {}

class GroupIncidentTypeQuestionFailedState
    extends GroupIncidentTypeQuestionState {
  final String? message;

  GroupIncidentTypeQuestionFailedState({this.message});

  @override
  List<Object?> get props => [message];
}

class GetGroupIncidentTypeQuestionsNotFoundState
    extends GroupIncidentTypeQuestionState {}

class GetGroupIncidentTypeQuestionsSuccessState
    extends GroupIncidentTypeQuestionState {
  final List<GroupIncidentTypeQuestionDto> model;

  GetGroupIncidentTypeQuestionsSuccessState(this.model);

  @override
  List<Object?> get props => [model];
}

class AddGroupIncidentTypeQuestionSuccessState
    extends GroupIncidentTypeQuestionState {}

class UpdateGroupIncidentTypeQuestionSuccessState
    extends GroupIncidentTypeQuestionState {}

class DeleteGroupIncidentTypeQuestionSuccessState
    extends GroupIncidentTypeQuestionState {}

class GetIncidentTypesSuccessState extends GroupIncidentTypeQuestionState {
  final List<GroupIncidentTypeModel> incidentTypes;

  GetIncidentTypesSuccessState(this.incidentTypes);

  @override
  List<Object?> get props => [incidentTypes];
}

class GetQuestionSuccessState extends GroupIncidentTypeQuestionState {
  final GroupIncidentTypeQuestionDto questionDto;

  GetQuestionSuccessState(this.questionDto);

  @override
  List<Object?> get props => [questionDto];
}

class GetBranchesSuccessState extends GroupIncidentTypeQuestionState {
  final List<GroupBranchDto> branches;

  GetBranchesSuccessState(this.branches);

  @override
  List<Object?> get props => [branches];
}

class BranchChangedState extends GroupIncidentTypeQuestionState {
  final String? branchId;

  BranchChangedState(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class RefreshQuestionsState extends GroupIncidentTypeQuestionState {}

class ChangeQuestionOrderSuccessState extends GroupIncidentTypeQuestionState {}

class GroupIncidentTypeQuestionBloc extends Bloc<GroupIncidentTypeQuestionEvent,
    GroupIncidentTypeQuestionState> {
  final IGroupIncidentTypeQuestionApi _api;
  final IGroupIncidentTypeApi _incidentTypeApi;
  final IGroupBranchApi _branchApi;
  GroupIncidentTypeQuestionBloc(
      this._api, this._incidentTypeApi, this._branchApi)
      : super(GroupIncidentTypeQuestionInitialState());

  @override
  Stream<GroupIncidentTypeQuestionState> mapEventToState(
      GroupIncidentTypeQuestionEvent event) async* {
    if (event is GetQuestions) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _api.get(
          event.groupId,
          event.filter,
          event.branchId!,
          event.incidentTypeId != null && event.incidentTypeId!.isNotEmpty
              ? event.incidentTypeId
              : null);

      if (result is OkData<List<GroupIncidentTypeQuestionDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetGroupIncidentTypeQuestionsSuccessState(result.dto);
          return;
        } else {
          yield GetGroupIncidentTypeQuestionsNotFoundState();
          return;
        }
      }
      if (result is BadData<List<GroupIncidentTypeQuestionDto>>) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
        return;
      }
    }
    if (event is AddQuestion) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _api.add(event.groupId, event.dto);
      if (result is Ok) {
        yield AddGroupIncidentTypeQuestionSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is UpdateQuestion) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result =
          await _api.update(event.groupId, event.incidentTypeId, event.dto);
      if (result is Ok) {
        yield UpdateGroupIncidentTypeQuestionSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is DeleteQuestion) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _api.delete(event.id, event.questionId);
      if (result is Ok) {
        yield DeleteGroupIncidentTypeQuestionSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is GetIncidents) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _incidentTypeApi.get("", null);
      if (result is OkData<List<GroupIncidentTypeDto>>) {
        yield GetIncidentTypesSuccessState(
            result.dto.map((e) => GroupIncidentTypeModel.fromDto(e)).toList());
      } else if (result is BadData<List<GroupIncidentTypeDto>>) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is GetQuestion) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _api.getOne(event.id);
      if (result is OkData<GroupIncidentTypeQuestionDto>) {
        yield GetQuestionSuccessState(result.dto);
      } else if (result is BadData<GroupIncidentTypeQuestionDto>) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is GetBranches) {
      yield GroupIncidentTypeQuestionLoadingState();

      var result = await _branchApi.getGroupBranches(event.groupId, '');
      if (result is OkData<List<GroupBranchDto>>) {
        yield GetBranchesSuccessState(result.dto);
      } else if (result is BadData<List<GroupBranchDto>>) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }

    if (event is BranchChangedEvent) {
      yield GroupIncidentTypeQuestionLoadingState();
      yield BranchChangedState(event.branchId);
      return;
    }

    if (event is RefreshQuestions) {
      yield GroupIncidentTypeQuestionLoadingState();
      yield RefreshQuestionsState();
      return;
    }

    if (event is ChangeQuestionOrder) {
      yield GroupIncidentTypeQuestionLoadingState();
      var result = await _api.changeQuestionOrder(
          event.incidentTypeId, event.questionId, event.order);
      if (result is Ok) {
        yield ChangeQuestionOrderSuccessState();
      } else if (result is Bad) {
        yield GroupIncidentTypeQuestionFailedState(message: result.message);
      } else {
        yield GroupIncidentTypeQuestionFailedState();
      }
    }
  }
}
