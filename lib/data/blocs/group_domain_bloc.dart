import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/api/group_domain_api.dart';
import 'package:rescu_organization_portal/data/dto/group_domain_dto.dart';
import 'package:rescu_organization_portal/data/models/group_domain_model.dart';

// Events
abstract class GroupDomainEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetGroupDomains extends GroupDomainEvent {
  final String searchValue;

  GetGroupDomains(this.searchValue);

  @override
  List<Object> get props => [searchValue];
}

class GetGroupDomain extends GroupDomainEvent {
  final String id;

  GetGroupDomain(this.id);

  @override
  List<Object> get props => [id];
}

class ViewGroupDomainDetails extends GroupDomainEvent {
  final String userId;

  ViewGroupDomainDetails(this.userId);

  @override
  List<Object> get props => [userId];
}

class DeleteGroupDomain extends GroupDomainEvent {
  final String userId;

  DeleteGroupDomain(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddGroupDomain extends GroupDomainEvent {
  final GroupDomainModel groupDomain;

  AddGroupDomain(this.groupDomain);

  @override
  List<Object> get props => [groupDomain];
}

class UpdateGroupDomain extends GroupDomainEvent {
  final GroupDomainModel groupDomain;

  UpdateGroupDomain(this.groupDomain);

  @override
  List<Object> get props => [groupDomain];
}

// States
abstract class GroupDomainState extends Equatable {
  @override
  List<Object> get props => [];
}

class GroupDomainInitialState extends GroupDomainState {}

class GroupDomainLoadingState extends GroupDomainState {}

class GroupDomainUnknownErrorState extends GroupDomainState {}

class GetGroupDomainsSuccessState extends GroupDomainState {
  final List<GroupDomainModel> groupDomains;

  GetGroupDomainsSuccessState(this.groupDomains);

  @override
  List<Object> get props => [groupDomains];
}

class GetGroupDomainSuccessState extends GroupDomainState {
  final GroupDomainModel groupDomain;
  GetGroupDomainSuccessState(this.groupDomain);

  @override
  List<Object> get props => [groupDomain];
}

class GetGroupDomainsNotFoundState extends GroupDomainState {}

class GetGroupDomainNotFoundState extends GroupDomainState {}

class GetGroupDomainsErrorState extends GroupDomainState {}

class GetGroupDomainErrorState extends GroupDomainState {
  final String errorMessage;
  GetGroupDomainErrorState(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class UpdateGroupDomainSuccessState extends GroupDomainState {}

class UpdateGroupDomainErrorState extends GroupDomainState {
  final String errorMessage;
  UpdateGroupDomainErrorState(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class DeleteGroupDomainErrorState extends GroupDomainState {}

class DeleteGroupDomainSuccessState extends GroupDomainState {}

class ResetPasswordSuccessState extends GroupDomainState {}

class ResetPasswordErrorState extends GroupDomainState {}

class AddGroupDomainSuccessState extends GroupDomainState {}

class AddGroupDomainErrorState extends GroupDomainState {
  final String message;

  AddGroupDomainErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class GroupDomainBloc extends Bloc<GroupDomainEvent, GroupDomainState> {
  final IGroupDomainApi _groupDomainApi;
  GroupDomainBloc(this._groupDomainApi) : super(GroupDomainInitialState());

  @override
  Stream<GroupDomainState> mapEventToState(GroupDomainEvent event) async* {
    if (event is GetGroupDomains) {
      yield GroupDomainLoadingState();
      var result = await _groupDomainApi.getGroupDomains(event.searchValue);
      if (result is OkData<List<GroupDomainDto>>) {
        yield GetGroupDomainsSuccessState(
            result.dto.map((e) => GroupDomainModel.fromDto(e)).toList());
        return;
      } else if (result is BadData<List<GroupDomainDto>>) {
        yield GetGroupDomainsNotFoundState();
        return;
      }
      yield GetGroupDomainsErrorState();
    }
    if (event is UpdateGroupDomain) {
      yield GroupDomainLoadingState();

      var result = await _groupDomainApi.updateGroupDomain(
          event.groupDomain.toDto(), event.groupDomain.id);

      if (result is Ok) {
        yield UpdateGroupDomainSuccessState();
        return;
      }
      if (result is Bad) {
        yield UpdateGroupDomainErrorState(result.message);
      }
    }
  }
}

class AddGroupDomainBloc extends Bloc<GroupDomainEvent, GroupDomainState> {
  final IGroupDomainApi _groupDomainApi;
  AddGroupDomainBloc(this._groupDomainApi) : super(GroupDomainInitialState());

  @override
  Stream<GroupDomainState> mapEventToState(GroupDomainEvent event) async* {
    if (event is AddGroupDomain) {
      yield GroupDomainLoadingState();
      var result =
          await _groupDomainApi.addGroupDomain(event.groupDomain.toDto());
      if (result is Ok) {
        yield AddGroupDomainSuccessState();
        return;
      } else if (result is Bad) {
        yield AddGroupDomainErrorState(result.message);
        return;
      }
    }
  }
}

class ViewGroupDomainBloc extends Bloc<GroupDomainEvent, GroupDomainState> {
  final IGroupDomainApi _groupDomainApi;
  ViewGroupDomainBloc(this._groupDomainApi) : super(GroupDomainInitialState());

  @override
  Stream<GroupDomainState> mapEventToState(GroupDomainEvent event) async* {
    if (event is GetGroupDomain) {
      yield GroupDomainLoadingState();
      var result = await _groupDomainApi.getGroupDomain(event.id);
      if (result is OkData<GroupDomainDto>) {
        yield GetGroupDomainSuccessState(GroupDomainModel.fromDto(result.dto));
        return;
      } else if (result is BadData<GroupDomainDto>) {
        yield GetGroupDomainErrorState(result.message);
        return;
      }
    }
  }
}
