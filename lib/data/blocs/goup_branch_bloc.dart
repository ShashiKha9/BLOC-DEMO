import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';

abstract class GroupBranchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupBranches extends GroupBranchEvent {
  final String groupId;
  final String filter;

  GetGroupBranches(this.groupId, this.filter);

  @override
  List<Object?> get props => [groupId];
}

class DeleteGroupBranch extends GroupBranchEvent {
  final String groupId;
  final String branchId;

  DeleteGroupBranch(this.groupId, this.branchId);

  @override
  List<Object> get props => [groupId, branchId];
}

class AddGroupBranch extends GroupBranchEvent {
  final GroupBranchDto branch;

  AddGroupBranch(this.branch);

  @override
  List<Object> get props => [branch];
}

class UpdateGroupBranch extends GroupBranchEvent {
  final GroupBranchDto branch;

  UpdateGroupBranch(this.branch);

  @override
  List<Object> get props => [branch];
}

class ActivateDeactivateGroupBranch extends GroupBranchEvent {
  final GroupBranchDto branch;

  ActivateDeactivateGroupBranch(this.branch);

  @override
  List<Object> get props => [branch];
}

abstract class GroupBranchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupBranchInitial extends GroupBranchState {}

class GroupBranchLoading extends GroupBranchState {}

class GroupBranchLoaded extends GroupBranchState {
  final List<GroupBranchDto> branches;

  GroupBranchLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class GroupBranchNotFoundState extends GroupBranchState {}

class GroupBranchError extends GroupBranchState {
  final String message;

  GroupBranchError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupBranchDeleteSuccess extends GroupBranchState {}

class GroupBranchAddSuccess extends GroupBranchState {}

class ActivateDeactivateGroupBranchSuccess extends GroupBranchState {}

class GroupBranchUpdateSuccess extends GroupBranchState {}

class GroupBranchBloc extends Bloc<GroupBranchEvent, GroupBranchState> {
  final IGroupBranchApi _api;
  GroupBranchBloc(this._api) : super(GroupBranchInitial());

  @override
  Stream<GroupBranchState> mapEventToState(GroupBranchEvent event) async* {
    if (event is GetGroupBranches) {
      yield GroupBranchLoading();
      var result = await _api.getGroupBranches(event.groupId, event.filter);

      if (result is OkData<List<GroupBranchDto>>) {
        if (result.dto.isEmpty) {
          yield GroupBranchNotFoundState();
        }
        yield GroupBranchLoaded(result.dto);
        return;
      }

      if (result is BadData<List<GroupBranchDto>>) {
        yield GroupBranchError(result.message);
        return;
      }
    }
    if (event is ActivateDeactivateGroupBranch) {
      yield GroupBranchLoading();
      var result = await _api.updateGroupBranch(event.branch);

      if (result is Ok) {
        yield ActivateDeactivateGroupBranchSuccess();
        return;
      }

      if (result is Bad) {
        yield GroupBranchError(result.message);
        return;
      }
    }
  }
}

class AddUpdateGroupBranchBloc
    extends Bloc<GroupBranchEvent, GroupBranchState> {
  final IGroupBranchApi _api;

  AddUpdateGroupBranchBloc(this._api) : super(GroupBranchInitial());

  @override
  Stream<GroupBranchState> mapEventToState(GroupBranchEvent event) async* {
    if (event is AddGroupBranch) {
      yield GroupBranchLoading();
      var result = await _api.addGroupBranch(event.branch);

      if (result is Ok) {
        yield GroupBranchAddSuccess();
        return;
      }

      if (result is Bad) {
        yield GroupBranchError(result.message);
        return;
      }
    }
    if (event is UpdateGroupBranch) {
      yield GroupBranchLoading();
      var result = await _api.updateGroupBranch(event.branch);

      if (result is Ok) {
        yield GroupBranchUpdateSuccess();
        return;
      }

      if (result is Bad) {
        yield GroupBranchError(result.message);
        return;
      }
    }
  }
}
