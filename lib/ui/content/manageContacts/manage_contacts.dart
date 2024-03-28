import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import '../../../data/blocs/group_manage_contacts_bloc.dart';
import '../../../data/dto/group_manage_contacts_dto.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_container.dart';
import '../../widgets/text_input_decoration.dart';

class ManageGroupContactsContent extends BaseModalRouteState {
  final LoadingController _loadingController = LoadingController();
  final Map<int, bool> _checkboxState = {};
  final String _groupId;
  String? _selectedFilter;
  String? _selectedBranchId;
  double? _dataRowHeight;
  int maxIncidents = 0;

  ManageGroupContactsContent(this._groupId);
  List<GroupManageContactBranchDto> tableData = [];
  List<ContactBranch> branchData = [];

  @override
  void initState() {
    super.initState();

    context
        .read<GroupManageContactsBloc>()
        .add(GetManageContacts(_groupId, _selectedFilter, _selectedBranchId));
    for (int i = 0; i < tableData.length; i++) {
      _checkboxState[i] = false;
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return LoadingContainer(
        controller: _loadingController,
        child: BlocListener(
            bloc: context.read<GroupManageContactsBloc>(),
            listener: (BuildContext context, state) {
              if (state is GroupManageContactsLoadingState) {
                _loadingController.show();
              } else if (state is GroupManageContactsNotFoundState) {
                tableData.clear();
                _loadingController.hide();
                setState(() {});
              } else if (state is UpdateManageContactsSuccessState) {
                _loadingController.hide();
                context.read<GroupManageContactsBloc>().add(GetManageContacts(
                    _groupId, _selectedFilter, _selectedBranchId));
              } else if (state is UpdateManageContactsErrorState) {
                _loadingController.hide();
              } else {
                _loadingController.hide();
                if (state is GetManageContactsSuccessState) {
                  tableData.clear();
                  tableData = state.manageContactsData;

                  if (branchData.isEmpty) {
                    branchData.add(ContactBranch(name: "All"));
                    Set<String> uniqueIds = {};
                    for (var data in tableData) {
                      if (!uniqueIds.contains(data.contactBranch?.branchId)) {
                        uniqueIds.add(data.contactBranch?.branchId ?? "");
                        branchData.add(data.contactBranch!);
                      }

                      if ((data.contactBranch?.contactBranchesIncidents
                                  ?.length ??
                              0) >
                          maxIncidents) {
                        maxIncidents = data.contactBranch!
                                .contactBranchesIncidents!.length +
                            1;

                        _dataRowHeight = ((maxIncidents / 3) * 70);
                      }
                    }
                  }

                  setState(() {});
                }
              }
            },
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Name, Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _selectedFilter = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration:
                                TextInputDecoration(labelText: "Select Branch"),
                            isExpanded: true,
                            hint: const Text("All"),
                            isDense: true,
                            value: _selectedBranchId,
                            items: branchData.map((branchName) {
                              return DropdownMenuItem(
                                child: Text(branchName.name ?? ""),
                                value: branchName.branchId ?? "",
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranchId = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        AppButtonWithIcon(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            context.read<GroupManageContactsBloc>().add(
                                GetManageContacts(_groupId, _selectedFilter,
                                    _selectedBranchId));
                          },
                          buttonText: "Search",
                        ),
                      ],
                    ),
                  ],
                ),
                if (tableData.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowHeight: 55,
                          dataRowHeight: _dataRowHeight ?? 70,
                          columns: [
                            const DataColumn(label: Text('Name')),
                            const DataColumn(label: Text('Phone Number')),
                            const DataColumn(label: Text('Email')),
                            DataColumn(
                              label: Expanded(
                                child: Row(
                                  children: [
                                    const Text('Branch'),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Row(
                                  children: [
                                    const Text('Incidents'),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: tableData.asMap().entries.map<DataRow>((entry) {
                            final int index = entry.key;
                            final GroupManageContactBranchDto data =
                                entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text(data.name ?? "name")),
                                DataCell(
                                    Text(data.phoneNumber ?? "phoneNumber")),
                                DataCell(Text(data.email ?? "email")),
                                DataCell(
                                  Wrap(
                                    spacing: 8.0,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value:
                                                data.contactBranch?.canAccess ??
                                                    false,
                                            onChanged: (newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  _checkboxState[index] =
                                                      newValue;
                                                  data.contactBranch
                                                      ?.canAccess = newValue;
                                                  for (var incident in data
                                                          .contactBranch
                                                          ?.contactBranchesIncidents ??
                                                      []) {
                                                    incident.canAccess =
                                                        newValue;
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                          Text(data.contactBranch?.name ?? ''),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Wrap(
                                        spacing: 8.0,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: _allIncidentsSelected(data
                                                    .contactBranch
                                                    ?.contactBranchesIncidents),
                                                onChanged: (newValue) {
                                                  if (newValue != null) {
                                                    setState(() {
                                                      data.contactBranch
                                                              ?.canAccess =
                                                          newValue;
                                                      for (var incident in data
                                                              .contactBranch
                                                              ?.contactBranchesIncidents ??
                                                          []) {
                                                        incident.canAccess =
                                                            newValue;
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                              const Text('All'),
                                            ],
                                          ),
                                          ...(data.contactBranch
                                                      ?.contactBranchesIncidents ??
                                                  [])
                                              .asMap()
                                              .entries
                                              .map<Widget>((entry) {
                                            final ContactBranchesIncidents
                                                incident = entry.value;
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  value: incident.canAccess ??
                                                      false,
                                                  onChanged: (newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        incident.canAccess =
                                                            newValue;

                                                        for (var all in data
                                                            .contactBranch!
                                                            .contactBranchesIncidents!) {
                                                          if (all.canAccess ==
                                                              true) {
                                                            data.contactBranch
                                                                    ?.canAccess =
                                                                true;
                                                            break;
                                                          } else {
                                                            data.contactBranch
                                                                    ?.canAccess =
                                                                false;
                                                          }
                                                        }
                                                      });
                                                    }
                                                  },
                                                ),
                                                Text(incident.name ?? ''),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                DataCell(
                                  AppButtonWithIcon(
                                    icon: const Icon(Icons.save),
                                    onPressed: () async {
                                      context
                                          .read<GroupManageContactsBloc>()
                                          .add(UpdateManageContacts(
                                              _groupId, data.inviteId, data));
                                    },
                                    buttonText: "Update",
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            )));
  }

  double calculateRowHeight() {
    return 120;
  }

  bool _allIncidentsSelected(List<ContactBranchesIncidents>? incidents) {
    if (incidents == null || incidents.isEmpty) {
      return false;
    }

    for (var incident in incidents) {
      if (!(incident.canAccess ?? false)) {
        return false;
      }
    }

    return true;
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [];
  }

  @override
  String getTitle() {
    return "Manage Contacts";
  }
}
