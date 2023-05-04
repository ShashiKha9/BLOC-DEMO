import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/blocs/group_incident_contact_bloc.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';
import 'add_group_contact.dart';

class GroupContactsContent extends StatefulWidget with FloatingActionMixin {
  final String groupId;
  const GroupContactsContent({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupContactsContent> createState() => _GroupContactsContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupContactModelState(groupId));
    })).then((_) {
      context
          .read<GroupIncidentContactBloc>()
          .add(GetGroupIncidentContacts(groupId, ""));
    });
  }
}

class _GroupContactsContentState extends State<GroupContactsContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];

  @override
  void initState() {
    context
        .read<GroupIncidentContactBloc>()
        .add(GetGroupIncidentContacts(widget.groupId, _searchValue));
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
        bloc: context.read<GroupIncidentContactBloc>(),
        listener: (context, state) {
          if (state is GroupIncidentLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GetGroupIncidentContactsSuccessState) {
              _contacts.clear();
              _contacts.addAll(state.contacts.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () => AddUpdateGroupContactModelState(
                            widget.groupId,
                            contact: e));
                  })).then((_) {
                    context
                        .read<GroupIncidentContactBloc>()
                        .add(GetGroupIncidentContacts(widget.groupId, ""));
                  });
                }));
                contextualItems.add(AdaptiveItemButton(
                    "Delete", const Icon(Icons.delete), () async {
                  showConfirmationDialog(
                      context: context,
                      body: "Are you sure you want to this record?",
                      onPressedOk: () {
                        context.read<GroupIncidentContactBloc>().add(
                            DeleteGroupIncidentContact(widget.groupId, e.id!));
                      });
                }));
                return AdaptiveListItem(
                    "Name: ${e.firstName} ${e.lastName}",
                    "Contact Number: ${e.phoneNumber}\nEmail: ${e.email ?? ""}\nDesignation: ${e.designation ?? ""}",
                    const Icon(Icons.person),
                    contextualItems,
                    onPressed: () {});
              }));
              setState(() {});
            }
            if (state is GroupIncidentErrorState) {
              ToastDialog.error(MessagesConst.internalServerError);
            }
            if (state is GetGroupIncidentContactsNotFoundState) {
              _contacts.clear();
              ToastDialog.warning("No records found");
              setState(() {});
            }
            if (state is DeleteGroupIncidentContactSuccessState) {
              ToastDialog.success("Record deleted successfully");
              context
                  .read<GroupIncidentContactBloc>()
                  .add(GetGroupIncidentContacts(widget.groupId, _searchValue));
            }
          }
        },
        child: SearchableList(
            searchHint: "First Name, Last Name",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context
                  .read<GroupIncidentContactBloc>()
                  .add(GetGroupIncidentContacts(widget.groupId, _searchValue));
            },
            list: _contacts),
      ),
    );
  }
}
