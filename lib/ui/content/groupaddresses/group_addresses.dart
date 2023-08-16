import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/ui/content/groupaddresses/copy_branch_address.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';

import '../../../data/blocs/group_address_bloc.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';
import 'add_group_address.dart';

class GroupAddressesContent extends StatefulWidget
    with FloatingActionMixin, AppBarBranchSelectionMixin {
  final String groupId;
  final String? selectedBranchId;

  GroupAddressesContent(
      {Key? key, required this.groupId, this.selectedBranchId})
      : super(key: key);

  @override
  State<GroupAddressesContent> createState() => _GroupAddressesContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () => AddUpdateGroupAddressModelState(groupId));
    })).then((_) {
      // Inform state to refresh the list
      context.read<GroupAddressBloc>().add(RefreshAddressList());
    });
  }

  @override
  void branchSelection(BuildContext context, String? branchId) {
    // Refresh the list with branchId
    context.read<GroupAddressBloc>().add(BranchChangedEvent(branchId));
  }
}

class _GroupAddressesContentState extends State<GroupAddressesContent> {
  String? _selectedBranchId;
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _addresses = [];

  @override
  void initState() {
    _selectedBranchId = widget.selectedBranchId;
    // context.read<GroupAddressBloc>().add(GetGroupIncidentAddresses(
    //     widget.groupId, _searchValue, _selectedBranchId));
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
        bloc: context.read<GroupAddressBloc>(),
        listener: (context, state) {
          if (state is GroupAddressLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GetGroupAddressesSuccessState) {
              _addresses.clear();
              state.addresses.sort((a, b) => b.isDefault ? 1 : -1);
              _addresses.addAll(state.addresses.map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
                if (!e.isDefault) {
                  contextualItems.add(AdaptiveItemButton(
                      "Set Default", const Icon(Icons.location_pin), () async {
                    showConfirmationDialog(
                        context: context,
                        body:
                            "Make ${e.name} address your default dispatch address?",
                        onPressedOk: () {
                          context.read<GroupAddressBloc>().add(
                              ChangeDefaultGroupIncidentAddress(
                                  widget.groupId, e.id!, e));
                        });
                  }));
                }
                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () => AddUpdateGroupAddressModelState(
                            widget.groupId,
                            address: e));
                  })).then((_) {
                    context.read<GroupAddressBloc>().add(
                        GetGroupIncidentAddresses(
                            widget.groupId, "", _selectedBranchId));
                  });
                }));
                if (!e.isDefault) {
                  contextualItems.add(AdaptiveItemButton(
                      "Delete", const Icon(Icons.delete), () async {
                    showConfirmationDialog(
                        context: context,
                        body: "Are you sure you want to this record?",
                        onPressedOk: () {
                          context.read<GroupAddressBloc>().add(
                              DeleteGroupIncidentAddress(
                                  widget.groupId, e.id!));
                        });
                  }));
                }
                return AdaptiveListItem(
                    e.name,
                    "${e.address1}, ${e.address2 ?? ""}\n${e.county ?? ""}, ${e.crossStreet ?? ""}\n${e.city}, ${e.state}, ${e.zipCode}",
                    const Icon(Icons.location_pin),
                    contextualItems,
                    onPressed: () {},
                    borderDecoration: e.isDefault
                        ? RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.white, //<-- SEE HERE
                            ),
                            borderRadius: BorderRadius.circular(5),
                          )
                        : null);
              }));
              setState(() {});
            }
            if (state is GroupAddressErrorState) {
              ToastDialog.error(MessagesConst.internalServerError);
            }
            if (state is GetGroupAddressesNotFoundState) {
              _addresses.clear();
              ToastDialog.success("No records found");
              setState(() {});
            }
            if (state is DeleteGroupAddressSuccessState) {
              ToastDialog.success("Record deleted successfully");
              context.read<GroupAddressBloc>().add(GetGroupIncidentAddresses(
                  widget.groupId, _searchValue, _selectedBranchId));
            }
            if (state is ChangeDefaultGroupAddressSuccessState) {
              ToastDialog.success("Address updated successfully");
              context.read<GroupAddressBloc>().add(GetGroupIncidentAddresses(
                  widget.groupId, _searchValue, _selectedBranchId));
            }
            if (state is BranchChangedState) {
              _selectedBranchId = state.branchId;
              context.read<GroupAddressBloc>().add(GetGroupIncidentAddresses(
                  widget.groupId, _searchValue, _selectedBranchId));
            }

            if (state is RefreshAddressListState) {
              context.read<GroupAddressBloc>().add(GetGroupIncidentAddresses(
                  widget.groupId, _searchValue, _selectedBranchId));
            }
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
                    child: AppButtonWithIcon(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return ModalRouteWidget(
                              stateGenerator: () => CopyBranchAddressModalState(
                                  groupId: widget.groupId,
                                  branchId: _selectedBranchId!));
                        })).then((_) {
                          // Inform state to refresh the list
                          context
                              .read<GroupAddressBloc>()
                              .add(RefreshAddressList());
                        });
                      },
                      buttonText: "Copy From Branch",
                    )),
              ),
              Expanded(
                child: SearchableList(
                    searchHint: "Name",
                    searchIcon: const Icon(Icons.search),
                    onSearchSubmitted: (value) {
                      _searchValue = value;
                      context.read<GroupAddressBloc>().add(
                          GetGroupIncidentAddresses(
                              widget.groupId, _searchValue, _selectedBranchId));
                    },
                    list: _addresses),
              ),
            ]),
      ),
    );
  }
}
