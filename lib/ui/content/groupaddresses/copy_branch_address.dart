import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_address_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_address_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class CopyBranchAddressModalState extends BaseModalRouteState {
  final String groupId;
  final String branchId;

  CopyBranchAddressModalState(
      {required this.groupId, required this.branchId, Key? key});

  String? _selectedBranchId;
  List<GroupBranchDto> _branches = [];
  final List<GroupAddressDto> _selectedAddresses = [];
  List<GroupAddressDto> _addressList = [];
  final LoadingController _controller = LoadingController();

  @override
  void initState() {
    super.initState();
    context.read<CopyBranchAddressBloc>().add(GetBranches(groupId));
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
        bloc: context.read<CopyBranchAddressBloc>(),
        listener: (ctx, state) {
          if (state is CopyBranchAddressLoading) {
            setState(() {
              _controller.show();
            });
          } else {
            setState(() {
              _controller.hide();
            });

            if (state is GetBranchesSuccessState) {
              setState(() {
                state.branches.removeWhere((element) => element.id == branchId);
                _branches = state.branches;
                _selectedBranchId = _branches.first.id;
              });
              context
                  .read<CopyBranchAddressBloc>()
                  .add(GetBranchAddresses(groupId, _selectedBranchId));
            }
            if (state is GetBranchAddressesSuccessState) {
              _selectedAddresses.clear();
              state.addresses.sort((a, b) => b.isDefault ? 1 : -1);
              _addressList.clear();
              setState(() {
                _addressList = state.addresses;
              });
            }

            if (state is BranchAddressCopySuccessState) {
              ToastDialog.success("Address copied successfully.");
              Navigator.of(context).pop();
            }
          }
        },
        child: Form(
          child: Column(
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
                    context
                        .read<CopyBranchAddressBloc>()
                        .add(GetBranchAddresses(groupId, _selectedBranchId));
                  }),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView.builder(
                      itemCount: _addressList.length,
                      itemBuilder: (ctx, index) {
                        return AdaptiveListTile(
                            item: AdaptiveListItem(
                          _addressList[index].name,
                          "${_addressList[index].address1}, ${_addressList[index].address2 ?? ""}\n${_addressList[index].county ?? ""}, ${_addressList[index].crossStreet ?? ""}\n${_addressList[index].city}, ${_addressList[index].state}, ${_addressList[index].zipCode}",
                          _selectedAddresses.contains(_addressList[index])
                              ? const Icon(Icons.check_box_rounded)
                              : const Icon(Icons.check_box_outline_blank),
                          [],
                          onPressed: () {
                            setState(() {
                              _selectedAddresses.contains(_addressList[index])
                                  ? _selectedAddresses
                                      .remove(_addressList[index])
                                  : _selectedAddresses.add(_addressList[index]);
                            });
                          },
                        ));
                      }))
            ],
          ),
        ),
      ),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        context
            .read<CopyBranchAddressBloc>()
            .add(SaveBranchAddresses(groupId, branchId, _selectedAddresses));
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return "Copy Branch Address";
  }
}
