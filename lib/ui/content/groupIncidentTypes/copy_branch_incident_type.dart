import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_incident_type_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class CopyBranchIncidentTypeModalState extends BaseModalRouteState {
  final String groupId;
  final String branchId;
  final int existingIncidentTypeCount;

  CopyBranchIncidentTypeModalState(
      {required this.groupId,
      required this.branchId,
      required this.existingIncidentTypeCount});

  String? _selectedBranchId;
  List<GroupBranchDto> _branches = [];
  final List<GroupIncidentTypeDto> _selectedIncidentTypes = [];
  List<GroupIncidentTypeDto> _incidentTypeList = [];
  final LoadingController _controller = LoadingController();

  @override
  void initState() {
    super.initState();
    context.read<CopyBranchIncidentTypeBloc>().add(GetBranches(groupId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return LoadingContainer(
        controller: _controller,
        child: BlocListener(
          bloc: context.read<CopyBranchIncidentTypeBloc>(),
          listener: (ctx, state) {
            if (state is CopyIncidentTypeLoading) {
              setState(() {
                _controller.show();
              });
            } else {
              setState(() {
                _controller.hide();
              });

              if (state is GetBranchesSuccessState) {
                setState(() {
                  state.branches
                      .removeWhere((element) => element.id == branchId);
                  _branches = state.branches;
                  _selectedBranchId = _branches.first.id;
                });
                context
                    .read<CopyBranchIncidentTypeBloc>()
                    .add(GetBranchIncidentTypes(groupId, _selectedBranchId));
              }
              if (state is GetBranchIncidentTypesSuccessState) {
                _incidentTypeList.clear();
                _selectedIncidentTypes.clear();
                setState(() {
                  _incidentTypeList = state.incidentTypes;
                });
              }
              if (state is SaveIncidentTypesSuccessState) {
                ToastDialog.success("Incident types copied successfully");
                Navigator.of(context).pop();
              }
            }
          },
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                    hint: const Text("Switch Branch"),
                    isDense: true,
                    value: _selectedBranchId,
                    decoration: TextInputDecoration(labelText: "Select Branch"),
                    items: _branches
                        .map((e) => DropdownMenuItem(
                              child: Text(e.name),
                              value: e.id,
                            ))
                        .toList(),
                    onChanged: (value) {
                      _selectedBranchId = value;
                      context.read<CopyBranchIncidentTypeBloc>().add(
                          GetBranchIncidentTypes(groupId, _selectedBranchId));
                    }),
                const SizedBox(height: 10),
                Expanded(
                    child: ListView.builder(
                        itemCount: _incidentTypeList.length,
                        itemBuilder: (ctx, index) {
                          return AdaptiveListTile(
                              item: AdaptiveListItem(
                            "Name: ${_incidentTypeList[index].name}",
                            "Description: ${_incidentTypeList[index].description}",
                            _selectedIncidentTypes
                                    .contains(_incidentTypeList[index])
                                ? const Icon(Icons.check_box_rounded)
                                : const Icon(Icons.check_box_outline_blank),
                            [],
                            onPressed: () {
                              setState(() {
                                _selectedIncidentTypes
                                        .contains(_incidentTypeList[index])
                                    ? _selectedIncidentTypes
                                        .remove(_incidentTypeList[index])
                                    : _selectedIncidentTypes
                                        .add(_incidentTypeList[index]);
                              });
                            },
                          ));
                        }))
              ],
            ),
          ),
        ));
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        // if ((_selectedIncidentTypes.length + existingIncidentTypeCount) > 4) {
        //   ToastDialog.error(
        //       "Total of existing incident types ($existingIncidentTypeCount) and selected incident types (${_selectedIncidentTypes.length}) cannot be more than 4.");
        //   return;
        // }
        if (_selectedIncidentTypes.isNotEmpty) {
          context.read<CopyBranchIncidentTypeBloc>().add(
              SaveIncidentTypes(groupId, branchId, _selectedIncidentTypes));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return "Copy Branch Incident Types";
  }
}
