import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_report_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_history_dto.dart';

abstract class GroupIncidentHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupIncidentHistory extends GroupIncidentHistoryEvent {
  final String groupId;
  final String searchValue;
  final String branchId;
  GetGroupIncidentHistory(this.searchValue, this.branchId, this.groupId);

  @override
  List<Object?> get props => [searchValue, branchId, groupId];
}

class GetGroupIncidentHistoryDetails extends GroupIncidentHistoryEvent {
  final String id;

  GetGroupIncidentHistoryDetails(this.id);

  @override
  List<Object> get props => [id];
}

class BranchChangedEvent extends GroupIncidentHistoryEvent {
  final String? branchId;

  BranchChangedEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class CloseIncident extends GroupIncidentHistoryEvent {
  final String signalId;

  CloseIncident(this.signalId);

  @override
  List<Object> get props => [signalId];
}

abstract class GroupIncidentHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupIncidentHistoryInitial extends GroupIncidentHistoryState {}

class GroupIncidentHistoryLoading extends GroupIncidentHistoryState {}

class GroupIncidentHistoryLoaded extends GroupIncidentHistoryState {
  final List<GroupIncidentHistoryDto> groupIncidentHistory;

  GroupIncidentHistoryLoaded(this.groupIncidentHistory);

  @override
  List<Object> get props => [groupIncidentHistory];
}

class GroupIncidentHistoryDetailsLoaded extends GroupIncidentHistoryState {
  final GroupIncidentHistoryDto groupIncidentHistory;

  GroupIncidentHistoryDetailsLoaded(this.groupIncidentHistory);

  @override
  List<Object> get props => [groupIncidentHistory];
}

class GetGroupIncidentDetailError extends GroupIncidentHistoryState {
  final String message;

  GetGroupIncidentDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class GroupIncidentHistoryError extends GroupIncidentHistoryState {
  final String message;

  GroupIncidentHistoryError(this.message);

  @override
  List<Object> get props => [message];
}

class BranchChangedState extends GroupIncidentHistoryState {
  final String? branchId;

  BranchChangedState(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class RefreshIncidentList extends GroupIncidentHistoryState {}

class CloseIncidentSuccess extends GroupIncidentHistoryState {}

class GroupIncidentHistoryBloc
    extends Bloc<GroupIncidentHistoryEvent, GroupIncidentHistoryState> {
  final IGroupReportApi _groupReportApi;
  GroupIncidentHistoryBloc(this._groupReportApi)
      : super(GroupIncidentHistoryInitial());

  @override
  Stream<GroupIncidentHistoryState> mapEventToState(
      GroupIncidentHistoryEvent event) async* {
    if (event is GetGroupIncidentHistory) {
      yield GroupIncidentHistoryLoading();
      try {
        var result = await _groupReportApi.getGroupIncidentHistory(
            event.groupId, event.searchValue, event.branchId);

        if (result is OkData<List<GroupIncidentHistoryDto>>) {
          yield GroupIncidentHistoryLoaded(result.dto);
          return;
        }
        if (result is BadData<List<GroupIncidentHistoryDto>>) {
          yield GroupIncidentHistoryError(result.message);
          return;
        }
      } catch (e) {
        yield GroupIncidentHistoryError(e.toString());
      }
    }

    if (event is BranchChangedEvent) {
      yield GroupIncidentHistoryLoading();
      yield BranchChangedState(event.branchId);
    }

    if (event is GetGroupIncidentHistoryDetails) {
      yield GroupIncidentHistoryLoading();
      try {
        var result = await _groupReportApi.get(event.id);

        if (result is OkData<GroupIncidentHistoryDto>) {
          yield GroupIncidentHistoryDetailsLoaded(result.dto);
          return;
        }
        if (result is BadData<GroupIncidentHistoryDto>) {
          yield GetGroupIncidentDetailError(result.message);
          return;
        }
      } catch (e) {
        yield GetGroupIncidentDetailError(e.toString());
      }
    }

    if (event is CloseIncident) {
      yield GroupIncidentHistoryLoading();
      try {
        var result = await _groupReportApi.closeIncident(event.signalId);

        if (result is Ok) {
          yield CloseIncidentSuccess();
          return;
        }
        if (result is Bad) {
          yield GroupIncidentHistoryError(result.message);
          return;
        }
      } catch (e) {
        yield GroupIncidentHistoryError(e.toString());
      }
    }
  }
}
