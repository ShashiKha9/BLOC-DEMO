import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_history_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_history_dto.dart';
import 'package:rescu_organization_portal/data/helpers/date_time_helper.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_navigation.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentHistory/group_incident_detail.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/signal_icons.dart';

class GroupIncidentHistoryContent extends StatefulWidget
    with AppBarBranchSelectionMixin {
  final String groupId;
  final String branchId;
  const GroupIncidentHistoryContent(
      {Key? key, required this.groupId, required this.branchId})
      : super(key: key);

  @override
  State<GroupIncidentHistoryContent> createState() =>
      _GroupIncidentHistoryContentState();

  @override
  void branchSelection(BuildContext context, String? branchId) {
    context.read<GroupIncidentHistoryBloc>().add(BranchChangedEvent(branchId));
  }
}

class _GroupIncidentHistoryContentState
    extends State<GroupIncidentHistoryContent> {
  late String _selectedBranchId;
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _incidents = [];

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
        bloc: context.read<GroupIncidentHistoryBloc>(),
        listener: (context, GroupIncidentHistoryState state) {
          if (state is GroupIncidentHistoryLoading) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GroupIncidentHistoryLoaded) {
              _incidents.clear();
              _incidents.addAll(state.groupIncidentHistory.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];

                contextualItems.add(AdaptiveItemButton(
                    "View", const Icon(Icons.remove_red_eye), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () =>
                            ViewGroupIncidentDetailModalState(e.signalId));
                  }));
                }));

                if (e.closed == false && e.signalType == SignalType.incident) {
                  contextualItems.add(AdaptiveItemButton(
                      "Close", const Icon(Icons.close), () async {
                    showConfirmationDialog(
                        context: context,
                        body:
                            "The communication on the channel will be closed. "
                            "\nAre you sure you want to close this incident?",
                        onPressedOk: () {
                          context
                              .read<GroupIncidentHistoryBloc>()
                              .add(CloseIncident(e.signalId));
                        });
                  }));
                } else {
                  contextualItems.add(AdaptiveItemButton(
                      "Chat History", const Icon(Icons.chat_outlined),
                      () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return ModalRouteWidget(
                          stateGenerator: () =>
                              ViewGroupIncidentDetailModalState(e.signalId));
                    }));
                  }));
                }

                return AdaptiveListItem(
                    "Incident Type: ${e.incidentType}",
                    "Employee Name: ${e.username}"
                        "\nReported On: ${e.incidentDate != null ? DateTimeHelper.forDispatchDetails(e.incidentDate!) : ''}",
                    e.signalType != SignalType.incident
                        ? iconFromSignalCode(
                            signalType: e.signalType,
                            height: 25,
                            width: 25,
                            iconColor: Colors.white)
                        : e.iconData.isNotEmpty
                            ? Icon(deserializeIcon(jsonDecode(e.iconData)))
                            : const Icon(Icons.report),
                    contextualItems,
                    onPressed: () {});
              }));
              setState(() {});
            }
            if (state is GroupIncidentHistoryError) {
              ToastDialog.error(state.message);
            }
            if (state is BranchChangedState) {
              _selectedBranchId = state.branchId!;
              context.read<GroupIncidentHistoryBloc>().add(
                  GetGroupIncidentHistory(
                      _searchValue, _selectedBranchId, widget.groupId));
            }

            if (state is RefreshIncidentList) {
              context.read<GroupIncidentHistoryBloc>().add(
                  GetGroupIncidentHistory(
                      _searchValue, _selectedBranchId, widget.groupId));
            }

            if (state is CloseIncidentSuccess) {
              ToastDialog.success("Incident closed successfully");
              context.read<GroupIncidentHistoryBloc>().add(
                  GetGroupIncidentHistory(
                      _searchValue, _selectedBranchId, widget.groupId));
            }
          }
        },
        child: SearchableList(
            searchHint: "Incident Type, Employee Name",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context.read<GroupIncidentHistoryBloc>().add(
                  GetGroupIncidentHistory(
                      _searchValue, _selectedBranchId, widget.groupId));
            },
            list: _incidents),
      ),
    );
  }
}
