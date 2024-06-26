import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/ui/content/groupAdmins/add_group_admin.dart';

import '../../../data/blocs/group_admins_bloc.dart';
import '../../../data/constants/fleet_user_roles.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';
import '../../widgets/text_input_decoration.dart';
import '../manageContacts/manage_contacts.dart';

class GroupAdminsContent extends StatefulWidget with FloatingActionMixin {
  final String groupId;
  const GroupAdminsContent({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupAdminsContent> createState() => _GroupAdminsContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupAdminModelState(groupId));
    })).then((_) {
      context.read<GroupAdminBloc>().add(RefreshAdminList());
    });
  }
}

class _GroupAdminsContentState extends State<GroupAdminsContent> {
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
    context
        .read<GroupAdminBloc>()
        .add(GetGroupAdmins(widget.groupId, _searchValue, _active));
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
        bloc: context.read<GroupAdminBloc>(),
        listener: (context, state) {
          if (state is GroupAdminsLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GetGroupAdminsSuccessState) {
              _contacts.clear();
              _contacts.addAll(state.contacts.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () => AddUpdateGroupAdminModelState(
                            widget.groupId,
                            contact: e.clone()));
                  })).then((_) {
                    context
                        .read<GroupAdminBloc>()
                        .add(GetGroupAdmins(widget.groupId, "", _active));
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
                        var updateContact = e.clone();
                        updateContact.isActive = !e.isActive;
                        context.read<GroupAdminBloc>().add(
                            ActivateDeactivateGroupAdmin(
                                widget.groupId, e.id!, updateContact));
                      });
                }));

                return AdaptiveListItem(
                    "Name: ${e.firstName} ${e.lastName}",
                    "Contact Number: ${e.phoneNumber}\nEmail: ${e.email ?? ""}",
                    const Icon(Icons.person),
                    contextualItems,
                    onPressed: () {});
              }));
              setState(() {});
            }
            if (state is GroupAdminsErrorState) {
              ToastDialog.error(
                  state.error ?? MessagesConst.internalServerError);
            }
            if (state is GetGroupAdminsNotFoundState) {
              _contacts.clear();
              ToastDialog.warning("No records found");
              setState(() {});
            }
            if (state is RefreshAdminListState) {
              context
                  .read<GroupAdminBloc>()
                  .add(GetGroupAdmins(widget.groupId, _searchValue, _active));
            }
            if (state is ActivateDeActivateAdminSuccessState) {
              ToastDialog.success("Record updated successfully");
              context
                  .read<GroupAdminBloc>()
                  .add(GetGroupAdmins(widget.groupId, _searchValue, _active));
            }
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
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
                            context.read<GroupAdminBloc>().add(GetGroupAdmins(
                                widget.groupId, _searchValue, _active));
                          },
                          items: _activeFilter
                              .map((description, value) {
                                return MapEntry(
                                  description,
                                  DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(description),
                                  ),
                                );
                              })
                              .values
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  AppButtonWithIcon(
                    icon: const Icon(Icons.contacts_rounded),
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ModalRouteWidget(
                              stateGenerator: () =>
                                  ManageGroupContactsContent(widget.groupId, FleetUserRoles.admin))));
                    },
                    buttonText: "Manage Admins",
                  ),
                ],
              ),
            ),
            Expanded(
              child: SearchableList(
                searchHint: "First Name, Last Name",
                searchIcon: const Icon(Icons.search),
                onSearchSubmitted: (value) {
                  _searchValue = value;
                  context.read<GroupAdminBloc>().add(
                      GetGroupAdmins(widget.groupId, _searchValue, _active));
                },
                list: _contacts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
