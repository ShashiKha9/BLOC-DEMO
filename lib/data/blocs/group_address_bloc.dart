import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_info_api.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_info_dto.dart';

import '../api/group_address_api.dart';
import '../dto/group_address_dto.dart';

abstract class GroupAddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetGroupIncidentAddresses extends GroupAddressEvent {
  final String? groupId;
  final String? filter;
  final String? branchId;

  GetGroupIncidentAddresses(this.groupId, this.filter, this.branchId);

  @override
  List<Object?> get props => [groupId, filter, branchId];
}

class DeleteGroupIncidentAddress extends GroupAddressEvent {
  final String groupId;
  final String addressId;

  DeleteGroupIncidentAddress(this.groupId, this.addressId);

  @override
  List<Object> get props => [groupId, addressId];
}

class ChangeDefaultGroupIncidentAddress extends GroupAddressEvent {
  final String groupId;
  final String addressId;
  final GroupAddressDto address;

  ChangeDefaultGroupIncidentAddress(this.groupId, this.addressId, this.address);

  @override
  List<Object> get props => [groupId, addressId, address];
}

class AddGroupIncidentAddress extends GroupAddressEvent {
  final String groupId;
  final GroupAddressDto address;

  AddGroupIncidentAddress(this.groupId, this.address);

  @override
  List<Object> get props => [groupId, address];
}

class UpdateGroupIncidentAddress extends GroupAddressEvent {
  final String groupId;
  final String addressId;
  final GroupAddressDto address;

  UpdateGroupIncidentAddress(this.groupId, this.addressId, this.address);

  @override
  List<Object> get props => [groupId, addressId, address];
}

class GetBranches extends GroupAddressEvent {
  final String groupId;

  GetBranches(this.groupId);

  @override
  List<Object> get props => [groupId];
}

class BranchChangedEvent extends GroupAddressEvent {
  final String? branchId;

  BranchChangedEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

// This is just a notifier event to refresh the address list
class RefreshAddressList extends GroupAddressEvent {}

abstract class GroupAddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupAddressInitialState extends GroupAddressState {}

class GroupAddressLoadingState extends GroupAddressState {}

class GroupAddressErrorState extends GroupAddressState {}

class LoadGroupDetailsState extends GroupAddressState {
  final GroupInfoDto groupInfo;

  LoadGroupDetailsState(this.groupInfo);

  @override
  List<Object> get props => [groupInfo];
}

class GetGroupAddressesSuccessState extends GroupAddressState {
  final List<GroupAddressDto> addresses;

  GetGroupAddressesSuccessState(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class GetGroupAddressesNotFoundState extends GroupAddressState {}

class DeleteGroupAddressSuccessState extends GroupAddressState {}

class ChangeDefaultGroupAddressSuccessState extends GroupAddressState {}

class AddressAddedSuccessState extends GroupAddressState {}

class AddressUpdatedSuccessState extends GroupAddressState {}

class GetBranchesSuccessState extends GroupAddressState {
  final List<GroupBranchDto> branches;

  GetBranchesSuccessState(this.branches);

  @override
  List<Object> get props => [branches];
}

class BranchChangedState extends GroupAddressState {
  final String? branchId;

  BranchChangedState(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

// This is just a notifier state to refresh the address list
class RefreshAddressListState extends GroupAddressState {}

class GroupAddressBloc extends Bloc<GroupAddressEvent, GroupAddressState> {
  final IGroupInfoApi _groupInfoApi;
  final IGroupAddressApi _addressApi;
  GroupAddressBloc(this._groupInfoApi, this._addressApi)
      : super(GroupAddressInitialState());

  @override
  Stream<GroupAddressState> mapEventToState(GroupAddressEvent event) async* {
    if (event is GetGroupIncidentAddresses) {
      yield GroupAddressLoadingState();
      late String groupId;
      if (event.groupId == null) {
        var result = await _groupInfoApi.getLoggedInUserGroup();
        if (result is OkData<GroupInfoDto>) {
          yield LoadGroupDetailsState(result.dto);
          yield GroupAddressLoadingState();
        } else {
          yield GroupAddressErrorState();
          return;
        }
      } else {
        groupId = event.groupId!;
      }

      var result = await _addressApi.getGroupIncidentAddresses(
          groupId, event.filter, event.branchId);

      if (result is OkData<List<GroupAddressDto>>) {
        if (result.dto.isNotEmpty) {
          yield GetGroupAddressesSuccessState(result.dto);
        } else {
          yield GetGroupAddressesNotFoundState();
        }
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }

    if (event is DeleteGroupIncidentAddress) {
      yield GroupAddressLoadingState();
      var result = await _addressApi.deleteGroupIncidentAddress(
          event.groupId, event.addressId);
      if (result is Ok) {
        yield DeleteGroupAddressSuccessState();
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }

    if (event is ChangeDefaultGroupIncidentAddress) {
      yield GroupAddressLoadingState();
      event.address.isDefault = true;
      var result = await _addressApi.updateGroupIncidentAddress(
          event.groupId, event.addressId, event.address);

      if (result is Ok) {
        yield ChangeDefaultGroupAddressSuccessState();
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }

    if (event is BranchChangedEvent) {
      yield BranchChangedState(event.branchId);
      return;
    }

    if (event is RefreshAddressList) {
      yield RefreshAddressListState();
      return;
    }
  }
}

class AddUpdateGroupAddressBloc
    extends Bloc<GroupAddressEvent, GroupAddressState> {
  final IGroupAddressApi _addressApi;
  final IGroupBranchApi _branchApi;
  AddUpdateGroupAddressBloc(this._addressApi, this._branchApi)
      : super(GroupAddressInitialState());

  @override
  Stream<GroupAddressState> mapEventToState(GroupAddressEvent event) async* {
    if (event is AddGroupIncidentAddress) {
      yield GroupAddressLoadingState();

      var result = await _addressApi.addGroupIncidentAddress(
          event.groupId, event.address);

      if (result is Ok) {
        yield AddressAddedSuccessState();
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }
    if (event is UpdateGroupIncidentAddress) {
      yield GroupAddressLoadingState();

      var result = await _addressApi.updateGroupIncidentAddress(
          event.groupId, event.addressId, event.address);

      if (result is Ok) {
        yield AddressUpdatedSuccessState();
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }

    if (event is GetBranches) {
      yield GroupAddressLoadingState();

      var result = await _branchApi.getGroupBranches(event.groupId, '');

      if (result is OkData<List<GroupBranchDto>>) {
        yield GetBranchesSuccessState(result.dto);
        return;
      } else {
        yield GroupAddressErrorState();
        return;
      }
    }
  }
}
