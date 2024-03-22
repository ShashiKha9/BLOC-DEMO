import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import '../../../data/blocs/group_manage_contacts_bloc.dart';
import '../../../data/dto/group_manage_contacts_dto.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_container.dart';

class ManageGroupContactsContent extends BaseModalRouteState {
  final LoadingController _loadingController = LoadingController();
  final Map<int, bool> _checkboxState = {};
  final String _groupId;
  String? _selectedFilter;
  String? _selectedBranchId;

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
                            hint: const Text("Branch"),
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
                      child: DataTable(
                        dataRowHeight: 75,
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Phone Number')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Branch')),
                          DataColumn(label: Text('Incidents')),
                          DataColumn(label: Text('')),
                        ],
                        rows: tableData.map<DataRow>((data) {
                          return DataRow(
                            cells: [
                              DataCell(Text(data.name ?? "name")),
                              DataCell(Text(data.phoneNumber ?? "phoneNumber")),
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
                                          onChanged: (newValue) {},
                                        ),
                                        Text(data.contactBranch?.name ?? ''),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      children: (data.contactBranch
                                                  ?.contactBranchesIncidents ??
                                              [])
                                          .map<Widget>((incident) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value:
                                                  incident.canAccess ?? false,
                                              onChanged: (newValue) {},
                                            ),
                                            Text(incident.name ?? ''),
                                          ],
                                        );
                                      }).toList(),
                                    )
                                  ],
                                ),
                              )),
                              DataCell(
                                AppButtonWithIcon(
                                  icon: const Icon(Icons.save),
                                  onPressed: () async {},
                                  buttonText: "Update",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            )));
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
