import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_bloc.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypes/add_group_incident_type.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypes/copy_branch_incident_type.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';

import '../../../constants.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/custom_colors.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';

class GroupIncidentTypesContent extends StatefulWidget
    with FloatingActionMixin, AppBarBranchSelectionMixin {
  final String groupId;
  final String? branchId;
  const GroupIncidentTypesContent({
    Key? key,
    required this.groupId,
    required this.branchId,
  }) : super(key: key);

  @override
  State<GroupIncidentTypesContent> createState() =>
      _GroupIncidentTypesContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    context.read<GroupIncidentTypeBloc>().add(ClickedFabIconEvent());
  }

  @override
  void branchSelection(BuildContext context, String? branchId) {
    context.read<GroupIncidentTypeBloc>().add(BranchChangedEvent(branchId));
  }
}

class _GroupIncidentTypesContentState extends State<GroupIncidentTypesContent> {
  String? _selectedBranchId;
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];
  // int _totalIncidentCount = 0;
  bool _isPoliceDispatchAdded = true;
  bool _isDefaultIncidentChecked = false;

  @override
  void initState() {
    _selectedBranchId = widget.branchId;
    // context
    //     .read<GroupIncidentTypeBloc>()
    //     .add(GetIncidentTypesTotalCount(_selectedBranchId));
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
          bloc: context.read<GroupIncidentTypeBloc>(),
          listener: (context, state) {
            if (state is GroupIncidentTypeLoadingState) {
              _loadingController.show();
            } else {
              _loadingController.hide();
              if (state is ClickedFabIconState) {
                // if (_totalIncidentCount >= 4) {
                //   ToastDialog.error(
                //       "You can add a maximum of 4 incident types.");
                // } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                  return ModalRouteWidget(
                      stateGenerator: () =>
                          AddUpdateGroupIncidentTypeModelState(
                              widget.groupId, false));
                })).then((_) {
                  context
                      .read<GroupIncidentTypeBloc>()
                      .add(GetIncidentTypes("", _selectedBranchId));
                });
                //}
              }
              if (state is GetGroupIncidentTypesSuccessState) {
                _contacts.clear();
                _isPoliceDispatchAdded = state.model.any((element) =>
                    specialIncidentDispatchCodes
                        .contains(element.dispatchCode));
                _contacts.addAll(state.model.map((e) {
                  List<AdaptiveContextualItem> contextualItems = [];
                  contextualItems.add(AdaptiveItemButton(
                      "Edit", const Icon(Icons.edit), () async {
                    !e.specialDispatch
                        ? Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                            return ModalRouteWidget(
                                stateGenerator: () =>
                                    AddUpdateGroupIncidentTypeModelState(
                                        widget.groupId, e.specialDispatch,
                                        incidentType: e));
                          })).then((_) {
                            context
                                .read<GroupIncidentTypeBloc>()
                                .add(GetIncidentTypes("", _selectedBranchId));
                          })
                        : ToastDialog.warning(
                            "This is a default Incident type and cannot be altered.");
                  }));
                  contextualItems.add(AdaptiveItemButton(
                      "Delete", const Icon(Icons.delete), () async {
                    showConfirmationDialog(
                        context: context,
                        body: "Are you sure you want to delete this record?",
                        onPressedOk: () {
                          context
                              .read<GroupIncidentTypeBloc>()
                              .add(DeleteIncidentType(widget.groupId, e.id!));
                        });
                  }));
                  return AdaptiveListItem(
                      "Name: ${e.name}",
                      "Description: ${e.description}",
                      e.iconData != null
                          ? Icon(deserializeIcon(jsonDecode(e.iconData!)))
                          : const Icon(Icons.report),
                      contextualItems,
                      onPressed: () {});
                }));
                setState(() {});
              }
              if (state is GroupIncidentTypeFailedState) {
                ToastDialog.error(MessagesConst.internalServerError);
              }
              if (state is AddUpdateDefaultGroupIncidentTypeFailedState) {
                ToastDialog.error(
                    state.message ?? MessagesConst.internalServerError);
              }
              if (state is GetGroupIncidentTypesNotFoundState) {
                _contacts.clear();
                ToastDialog.warning("No records found");
                setState(() {});
              }
              if (state is DeleteGroupIncidentTypeSuccessState) {
                ToastDialog.success("Record deleted successfully");
                context
                    .read<GroupIncidentTypeBloc>()
                    .add(GetIncidentTypes(_searchValue, _selectedBranchId));
                // context
                //     .read<GroupIncidentTypeBloc>()
                //     .add(GetIncidentTypesTotalCount(_selectedBranchId));
              }
              if (state is AddDefaultGroupIncidentTypeSuccessState) {
                context
                    .read<GroupIncidentTypeBloc>()
                    .add(GetIncidentTypes(_searchValue, _selectedBranchId));
                // context
                //     .read<GroupIncidentTypeBloc>()
                //     .add(GetIncidentTypesTotalCount(_selectedBranchId));
              }
              if (state is BranchChangedState) {
                _selectedBranchId = state.branchId;
                context
                    .read<GroupIncidentTypeBloc>()
                    .add(GetIncidentTypes(_searchValue, _selectedBranchId));
                // context
                //     .read<GroupIncidentTypeBloc>()
                //     .add(GetIncidentTypesTotalCount(_selectedBranchId));
              }
              if (state is RefreshIncidentTypesState) {
                context
                    .read<GroupIncidentTypeBloc>()
                    .add(GetIncidentTypes(_searchValue, _selectedBranchId));
                // context
                //     .read<GroupIncidentTypeBloc>()
                //     .add(GetIncidentTypesTotalCount(_selectedBranchId));
              }
              // if (state is IncidentTypeCountLoaded) {
              //   _totalIncidentCount = state.count;
              // }
            }
          },
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !_isPoliceDispatchAdded
                                ? AppButtonWithIcon(
                                    icon: const Icon(Icons.local_police_rounded),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'DEFAULT INCIDENT'),
                                              content: Row(
                                                children: [
                                                  StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey
                                                                .withAlpha(125),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Checkbox(
                                                          activeColor: AppColor
                                                              .baseBackground,
                                                          value:
                                                              _isDefaultIncidentChecked,
                                                          onChanged:
                                                              (bool? value) {
                                                            if (value != null) {
                                                              setState(() {
                                                                _isDefaultIncidentChecked =
                                                                    value;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Icon(
                                                      Icons
                                                          .local_police_rounded,
                                                      color: Colors.black),
                                                  const SizedBox(width: 8),
                                                  const Text('Police'),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('ADD'),
                                                  onPressed: () {
                                                    if (_isDefaultIncidentChecked) {
                                                      context
                                                          .read<
                                                              GroupIncidentTypeBloc>()
                                                          .add(AddDefaultIncidentType(
                                                              widget.groupId,
                                                              _selectedBranchId!));
                                                      _isDefaultIncidentChecked =
                                                          false;
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      ToastDialog.warning(
                                                          "Please select the incident");
                                                    }
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('CANCEL'),
                                                  onPressed: () {
                                                    _isDefaultIncidentChecked =
                                                        false;
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    buttonText: "Add Default Incident Type",
                                  )
                                : const SizedBox(width: 16),
                            const SizedBox(width: 16),
                            AppButtonWithIcon(
                              icon: const Icon(Icons.copy),
                              onPressed: () async {
                                // if (_totalIncidentCount >= 4) {
                                //   ToastDialog.error(
                                //       "You can add a maximum of 4 incident types.");
                                //   return;
                                // }
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return ModalRouteWidget(
                                      stateGenerator: () =>
                                          CopyBranchIncidentTypeModalState(
                                              groupId: widget.groupId,
                                              branchId: _selectedBranchId!));
                                })).then((_) {
                                  // Inform state to refresh the list
                                  context
                                      .read<GroupIncidentTypeBloc>()
                                      .add(RefreshIncidentTypes());
                                });
                              },
                              buttonText: "Copy From Branch",
                            ),
                          ])),
                ),
                Expanded(
                    child: SearchableList(
                        searchHint: "Incident Type Name",
                        searchIcon: const Icon(Icons.search),
                        onSearchSubmitted: (value) {
                          _searchValue = value;
                          context.read<GroupIncidentTypeBloc>().add(
                              GetIncidentTypes(
                                  _searchValue, _selectedBranchId));
                        },
                        list: _contacts)),
              ])),
    );
  }
}
