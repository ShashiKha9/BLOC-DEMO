import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_address_api.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/dto/group_address_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';

abstract class CopyBranchAddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetBranches extends CopyBranchAddressEvent {
  final String? groupId;

  GetBranches(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GetBranchAddresses extends CopyBranchAddressEvent {
  final String groupId;
  final String? branchId;

  GetBranchAddresses(this.groupId, this.branchId);

  @override
  List<Object?> get props => [groupId, branchId];
}

class SaveBranchAddresses extends CopyBranchAddressEvent {
  final String groupId;
  final String branchId;
  final List<GroupAddressDto> addresses;

  SaveBranchAddresses(this.groupId, this.branchId, this.addresses);

  @override
  List<Object?> get props => [groupId, branchId, addresses];
}

abstract class CopyBranchAddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CopyBranchAddressInitial extends CopyBranchAddressState {}

class CopyBranchAddressLoading extends CopyBranchAddressState {}

class GetBranchesSuccessState extends CopyBranchAddressState {
  final List<GroupBranchDto> branches;

  GetBranchesSuccessState(this.branches);

  @override
  List<Object?> get props => [branches];
}

class GetBranchAddressesSuccessState extends CopyBranchAddressState {
  final List<GroupAddressDto> addresses;

  GetBranchAddressesSuccessState(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class BranchAddressCopySuccessState extends CopyBranchAddressState {}

class CopyBranchAddressBloc
    extends Bloc<CopyBranchAddressEvent, CopyBranchAddressState> {
  final IGroupBranchApi _branchApi;
  final IGroupAddressApi _addressApi;

  CopyBranchAddressBloc(this._branchApi, this._addressApi)
      : super(CopyBranchAddressInitial());

  @override
  Stream<CopyBranchAddressState> mapEventToState(
      CopyBranchAddressEvent event) async* {
    if (event is GetBranches) {
      yield CopyBranchAddressLoading();
      var result = await _branchApi.getGroupBranches(event.groupId!, "");
      if (result is OkData<List<GroupBranchDto>>) {
        yield GetBranchesSuccessState(result.dto);
      }
    } else if (event is GetBranchAddresses) {
      yield CopyBranchAddressLoading();
      var result = await _addressApi.getGroupIncidentAddresses(
          event.groupId, null, event.branchId);
      if (result is OkData<List<GroupAddressDto>>) {
        yield GetBranchAddressesSuccessState(result.dto);
      }
    }
    if (event is SaveBranchAddresses) {
      yield CopyBranchAddressLoading();
      event.addresses.map((e) => e.branchIds = [event.branchId]).toList();

      for (var element in event.addresses) {
        await _addressApi.addGroupIncidentAddress(event.groupId, element);
      }

      yield BranchAddressCopySuccessState();
    }
  }
}
