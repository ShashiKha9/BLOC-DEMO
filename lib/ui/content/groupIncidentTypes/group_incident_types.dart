import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_bloc.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypes/add_group_incident_type.dart';

import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';

class GroupIncidentTypesContent extends StatefulWidget
    with FloatingActionMixin {
  final String groupId;
  const GroupIncidentTypesContent({
    Key? key,
    required this.groupId,
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
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupIncidentTypeModelState(groupId));
    })).then((_) {
      context.read<GroupIncidentTypeBloc>().add(GetIncidentTypes(groupId, ""));
    });
  }
}

class _GroupIncidentTypesContentState extends State<GroupIncidentTypesContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];

  @override
  void initState() {
    context
        .read<GroupIncidentTypeBloc>()
        .add(GetIncidentTypes(widget.groupId, _searchValue));
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
            if (state is GetGroupIncidentTypesSuccessState) {
              _contacts.clear();
              _contacts.addAll(state.model.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () =>
                            AddUpdateGroupIncidentTypeModelState(widget.groupId,
                                incidentType: e));
                  })).then((_) {
                    context
                        .read<GroupIncidentTypeBloc>()
                        .add(GetIncidentTypes(widget.groupId, ""));
                  });
                }));
                contextualItems.add(AdaptiveItemButton(
                    "Delete", const Icon(Icons.delete), () async {
                  showConfirmationDialog(
                      context: context,
                      body: "Are you sure you want to this record?",
                      onPressedOk: () {
                        context
                            .read<GroupIncidentTypeBloc>()
                            .add(DeleteIncidentType(widget.groupId, e.id!));
                      });
                }));
                return AdaptiveListItem(
                    "Name: ${e.name}",
                    "Description: ${e.description}",
                    const Icon(Icons.report),
                    contextualItems,
                    onPressed: () {});
              }));
              setState(() {});
            }
            if (state is GroupIncidentTypeFailedState) {
              ToastDialog.error(MessagesConst.internalServerError);
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
                  .add(GetIncidentTypes(widget.groupId, _searchValue));
            }
          }
        },
        child: SearchableList(
            searchHint: "Incident Type Name",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context
                  .read<GroupIncidentTypeBloc>()
                  .add(GetIncidentTypes(widget.groupId, _searchValue));
            },
            list: _contacts),
      ),
    );
  }
}
