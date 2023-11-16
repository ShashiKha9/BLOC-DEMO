import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_history_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_history_dto.dart';
import 'package:rescu_organization_portal/data/helpers/date_time_helper.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class ViewGroupIncidentDetailModalState extends BaseModalRouteState {
  final String incidentId;

  ViewGroupIncidentDetailModalState(this.incidentId);

  final LoadingController _controller = LoadingController();

  @override
  void initState() {
    context
        .read<GroupIncidentHistoryBloc>()
        .add(GetGroupIncidentHistoryDetails(incidentId));
    super.initState();
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
          listener: (context, state) {
            if (state is GroupIncidentHistoryLoading) {
              _controller.show();
            } else {
              _controller.hide();
            }
          },
          bloc: context.read<GroupIncidentHistoryBloc>(),
          child:
              BlocBuilder<GroupIncidentHistoryBloc, GroupIncidentHistoryState>(
            builder: (context, state) {
              if (state is GroupIncidentHistoryDetailsLoaded) {
                return _buildIncidentDetails(state.groupIncidentHistory);
              }
              return Container();
            },
          ),
        ));
  }

  Widget _buildIncidentDetails(GroupIncidentHistoryDto incident) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            decoration: TextInputDecoration(labelText: "Incident Type"),
            controller: TextEditingController(
                text: incident.incidentType.isEmpty
                    ? incident.signalType.toString()
                    : incident.incidentType),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            decoration: TextInputDecoration(labelText: "Reported On"),
            controller: TextEditingController(
                text:
                    DateTimeHelper.forDispatchDetails(incident.incidentDate!)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            decoration: TextInputDecoration(labelText: "Employee Name"),
            controller: TextEditingController(text: incident.username),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            decoration: TextInputDecoration(labelText: "Reported At"),
            controller: TextEditingController(
                text: incident.address == null
                    ? "GPS Location"
                    : incident.address?.friendlyAddress),
          ),
        ),
        incident.address == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  readOnly: true,
                  decoration: TextInputDecoration(labelText: "Address"),
                  controller: TextEditingController(
                      text: "${incident.address?.address2} "
                          "${incident.address?.address}, "
                          "${incident.address?.city}, "
                          "${incident.address?.state}, "
                          "${incident.address?.postalCode}"),
                ),
              ),
        // Show participant list if incident type is incident
        incident.signalType == SignalType.incident
            ? SpacerSize.at(1.5)
            : Container(),
        incident.signalType == SignalType.incident
            ? const Text(
                "Participants",
                style: TextStyle(fontSize: 18),
              )
            : Container(),
        incident.signalType == SignalType.incident
            ? const Divider(
                thickness: 2,
              )
            : Container(),
        incident.signalType == SignalType.incident
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incident.participants.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      incident.participants[index].firstName +
                          " " +
                          incident.participants[index].lastName,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              )
            : Container(),
      ],
    ));
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return "Incident Details";
  }
}
