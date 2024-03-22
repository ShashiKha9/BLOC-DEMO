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
  String? _selectedBranch;
  final String groupId;

  ManageGroupContactsContent(this.groupId);
  List<GroupManageContactBranchDto> tableData = [];
  List<Map<String, dynamic>> tableData1 = [
    {
      'name': 'Sandeep',
      'username': 'sandeep@yopmail.com',
      'branch': ['Group QA'],
      'incidents': [
        'All',
        'test group qa',
        'QA reg',
        'QA reg 1',
        'QA reg 2',
        'QA reg 3',
        'QA reg 4',
        'QA reg 5'
      ]
    },
    {
      'name': 'Sandeep',
      'username': 'sandeep@yopmail.com',
      'branch': ['Sanfleet 01'],
      'incidents': ['All', 'test group qa']
    },
    {
      'name': 'Sandeep',
      'username': 'sandeep@yopmail.com',
      'branch': ['QA Regression'],
      'incidents': ['All', 'test group qa']
    },
    {
      'name': 'Alice',
      'username': 'alice@yopmail.com',
      'branch': ['Group QA'],
      'incidents': ['All', 'test group qa', 'QA reg']
    },
    {
      'name': 'Bob',
      'username': 'bob@yopmail.com',
      'branch': ['Group QA'],
      'incidents': ['All', 'test group qa']
    },
  ];

  @override
  void initState() {
    super.initState();

    context.read<GroupManageContactsBloc>().add(GetManageContacts(groupId));
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
                if (state is GetManageContactsSuccessState) {
                  tableData.clear();
                  tableData = state.manageContactsData;
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
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            hint: const Text("Branch"),
                            isDense: true,
                            value: _selectedBranch,
                            items: tableData
                                .where((element) =>
                                    element.contactBranch?.id != null)
                                .fold<Set<String>>(
                                    <String>{},
                                    (Set<String> set, element) => set
                                      ..add(
                                          element.contactBranch?.id ?? "")).map(
                                    (id) {
                              final branch = tableData
                                  .firstWhere((element) =>
                                      element.contactBranch?.id == id)
                                  .contactBranch;
                              return DropdownMenuItem(
                                child: Text(branch?.name ?? ""),
                                value: branch?.id ?? "",
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranch = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        AppButtonWithIcon(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            context
                                .read<GroupManageContactsBloc>()
                                .add(GetManageContacts(groupId));
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
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Username')),
                          DataColumn(label: Text('Phone Number')),
                          DataColumn(label: Text('Branch')),
                          DataColumn(label: Text('Incidents')),
                          DataColumn(label: Text('')),
                        ],
                        rows: tableData.map<DataRow>((data) {
                          return DataRow(
                            cells: [
                              DataCell(Text(data.name ?? "name")),
                              DataCell(Text(data.email ?? "email")),
                              DataCell(Text(data.phoneNumber ?? "phoneNumber")),
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
                              DataCell(
                                Wrap(
                                  spacing: 8.0,
                                  children: (data.contactBranch
                                              ?.contactBrancheIncidents ??
                                          [])
                                      .map<Widget>((incident) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: incident.canAccess ?? false,
                                          onChanged: (newValue) {},
                                        ),
                                        Text(incident.name ?? ''),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
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
