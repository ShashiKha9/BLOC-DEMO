import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/goup_branch_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_navigation.dart';
import 'package:rescu_organization_portal/ui/content/groupBranches/add_update_branch.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';

class GroupBranchesContent extends StatefulWidget with FloatingActionMixin {
  final String groupId;

  const GroupBranchesContent({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupBranchesContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupBranchModalState(groupId));
    })).then((_) {
      context.read<GroupBranchBloc>().add(GetGroupBranches(groupId, ""));
    });
  }
}

class _GroupBranchesContentState extends State<GroupBranchesContent> {
  final LoadingController _controller = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _branches = [];

  @override
  void initState() {
    context
        .read<GroupBranchBloc>()
        .add(GetGroupBranches(widget.groupId, _searchValue));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
        controller: _controller,
        blockPopOnLoad: true,
        child: BlocListener(
          bloc: context.read<GroupBranchBloc>(),
          listener: (ctx, state) {
            if (state is GroupBranchLoading) {
              setState(() {
                _controller.show();
              });
            } else {
              setState(() {
                _controller.hide();
              });

              if (state is GroupBranchLoaded) {
                _branches.clear();
                _branches.addAll(state.branches.map((e) {
                  List<AdaptiveContextualItem> contextualItems = [];

                  contextualItems.add(AdaptiveItemButton(
                      "Edit", const Icon(Icons.edit), () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (ctx) => ModalRouteWidget(
                                stateGenerator: () =>
                                    AddUpdateGroupBranchModalState(
                                        widget.groupId,
                                        groupBranch: e))))
                        .then((value) => context.read<GroupBranchBloc>().add(
                            GetGroupBranches(widget.groupId, _searchValue)));
                  }));

                  contextualItems.add(AdaptiveItemButton(
                      "${e.active ? "De-" : ""}Activate",
                      const Icon(Icons.manage_accounts), () async {
                    showConfirmationDialog(
                        context: context,
                        body:
                            "Are you sure you want to ${e.active ? "De-" : ""}Activate this record?",
                        onPressedOk: () {
                          var branch = GroupBranchDto(
                              id: e.id,
                              groupId: widget.groupId,
                              name: e.name,
                              active: !e.active);

                          context
                              .read<GroupBranchBloc>()
                              .add(ActivateDeactivateGroupBranch(branch));
                        });
                  }));

                  // contextualItems.add(AdaptiveItemButton(
                  //     "Delete", const Icon(Icons.delete), () async {
                  //   showConfirmationDialog(
                  //       context: context,
                  //       body: "Are you sure you want to this record?",
                  //       onPressedOk: () {
                  //         context.read<GroupInviteContactBloc>().add(
                  //             DeleteGroupInviteContact(widget.groupId, e.id!));
                  //       });
                  // }));

                  return AdaptiveListItem("Name: ${e.name}", null,
                      const Icon(Icons.apartment), contextualItems,
                      onPressed: () {});
                }));
              }
              if (state is GroupBranchNotFoundState) {
                _branches.clear();
                ToastDialog.warning("No records found");
                setState(() {});
              }
              if (state is ActivateDeactivateGroupBranchSuccess) {
                ToastDialog.success("Record updated successfully");
                context
                    .read<GroupBranchBloc>()
                    .add(GetGroupBranches(widget.groupId, _searchValue));
              }
            }
          },
          child: SearchableList(
            searchHint: "Branch Name",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context
                  .read<GroupBranchBloc>()
                  .add(GetGroupBranches(widget.groupId, _searchValue));
            },
            list: _branches,
          ),
        ));
  }
}
