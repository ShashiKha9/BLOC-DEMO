import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/dto/group_invite_contact_dto.dart';

import '../../../data/blocs/group_invite_contact_bloc.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';
import '../../widgets/text_input_decoration.dart';
import 'add_group_invite_contact.dart';

class GroupInviteContactsContent extends StatefulWidget
    with FloatingActionMixin, AppBarBranchSelectionMixin {
  final String groupId;
  final String? branchId;
  const GroupInviteContactsContent(
      {Key? key, required this.groupId, required this.branchId})
      : super(key: key);

  @override
  State<GroupInviteContactsContent> createState() =>
      _GroupInviteContactsContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupInviteContactModelState(groupId));
    })).then((_) {
      context.read<GroupInviteContactBloc>().add(RefreshContactList());
    });
  }

  @override
  void branchSelection(BuildContext context, String? branchId) {
    context.read<GroupInviteContactBloc>().add(BranchChangedEvent(branchId));
  }
}

class _GroupInviteContactsContentState
    extends State<GroupInviteContactsContent> {
  String? _selectedBranchId;
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];
  String _active = "active";
  final _activeFilter = {
    "All": "all",
    "Active": "active",
    "Inactive": "inactive"
  };

  @override
  void initState() {
    _selectedBranchId = widget.branchId;
    // context.read<GroupInviteContactBloc>().add(GetGroupInviteContacts(
    //     widget.groupId, _searchValue, FleetUserRoles.fleet, _selectedBranchId));
    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      controller: _loadingController,
      blockPopOnLoad: true,
      child: BlocListener(
        bloc: context.read<GroupInviteContactBloc>(),
        listener: (context, GroupInviteContactState state) {
          if (state is GroupInviteContactLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GetGroupInviteContactsSuccessState) {
              _contacts.clear();
              _contacts.addAll(state.contacts.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () =>
                            AddUpdateGroupInviteContactModelState(
                                widget.groupId,
                                contact: e));
                  })).then((_) {
                    context.read<GroupInviteContactBloc>().add(
                        GetGroupInviteContacts(widget.groupId, "",
                            FleetUserRoles.fleet, _selectedBranchId, _active));
                  });
                }));
                contextualItems.add(AdaptiveItemButton(
                    "${e.isActive ? "De-" : ""}Activate",
                    const Icon(Icons.manage_accounts), () async {
                  showConfirmationDialog(
                      context: context,
                      body:
                          "Are you sure you want to ${e.isActive ? "De-" : ""}Activate this record?",
                      onPressedOk: () {
                        var updateContact = GroupInviteContactDto(
                            firstName: e.firstName,
                            lastName: e.lastName,
                            phoneNumber: e.phoneNumber,
                            isActive: !e.isActive,
                            branchIds: e.branchIds,
                            canCloseChat: e.canCloseChat,
                            designation: e.designation,
                            email: e.email,
                            id: e.id,
                            incidentTypeList: e.incidentTypeList,
                            loginWith: e.loginWith,
                            role: FleetUserRoles.fleet);
                        context.read<GroupInviteContactBloc>().add(
                            ActivateDeactivateGroupInviteContact(
                                widget.groupId, e.id!, updateContact));
                      });
                }));

                return AdaptiveListItem(
                    "Name: ${e.firstName} ${e.lastName}",
                    "Contact Number: ${e.phoneNumber}\nEmail: ${e.email}",
                    const Icon(Icons.person),
                    contextualItems,
                    onPressed: () {});
              }));
              setState(() {});
            }
            if (state is GroupInviteContactErrorState) {
              ToastDialog.error(
                  state.error ?? MessagesConst.internalServerError);
            }
            if (state is GetGroupInviteContactsNotFoundState) {
              _contacts.clear();
              ToastDialog.warning("No records found");
              setState(() {});
            }
            if (state is DeleteGroupInviteContactSuccessState) {
              ToastDialog.success("Record deleted successfully");
              context.read<GroupInviteContactBloc>().add(GetGroupInviteContacts(
                  widget.groupId,
                  _searchValue,
                  FleetUserRoles.fleet,
                  _selectedBranchId,
                  _active));
            }
            if (state is ActivateDeActivateContactSuccessState) {
              ToastDialog.success("Record updated successfully");
              context.read<GroupInviteContactBloc>().add(GetGroupInviteContacts(
                  widget.groupId,
                  _searchValue,
                  FleetUserRoles.fleet,
                  _selectedBranchId,
                  _active));
            }
            if (state is BranchChangedState) {
              _selectedBranchId = state.branchId;
              context.read<GroupInviteContactBloc>().add(GetGroupInviteContacts(
                  widget.groupId,
                  _searchValue,
                  FleetUserRoles.fleet,
                  _selectedBranchId,
                  _active));
            }

            if (state is RefreshContactList) {
              context.read<GroupInviteContactBloc>().add(GetGroupInviteContacts(
                  widget.groupId,
                  _searchValue,
                  FleetUserRoles.fleet,
                  _selectedBranchId,
                  _active));
            }
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: DropdownButtonFormField<String>(
                      decoration: TextInputDecoration(labelText: "Select"),
                      value: _active,
                      isExpanded: true,
                      isDense: true,
                      onChanged: (value) {
                        setState(() {
                          _active = value ?? "";
                        });
                        context.read<GroupInviteContactBloc>().add(
                            GetGroupInviteContacts(
                                widget.groupId,
                                _searchValue,
                                FleetUserRoles.fleet,
                                _selectedBranchId,
                                _active));
                      },
                      items: _activeFilter
                          .map((description, value) {
                            return MapEntry(
                                description,
                                DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(description),
                                ));
                          })
                          .values
                          .toList()),
                ),
              ),
            ),
            Expanded(
              child: SearchableList(
                  searchHint: "First Name, Last Name, Contact Number",
                  searchIcon: const Icon(Icons.search),
                  onSearchSubmitted: (value) {
                    _searchValue = value;
                    context.read<GroupInviteContactBloc>().add(
                        GetGroupInviteContacts(widget.groupId, _searchValue,
                            FleetUserRoles.fleet, _selectedBranchId, _active));
                  },
                  list: _contacts),
            ),
          ],
        ),
      ),
    );
  }
}
