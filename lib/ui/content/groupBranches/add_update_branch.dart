import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/goup_branch_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddUpdateGroupBranchModalState extends BaseModalRouteState {
  final String groupId;
  final GroupBranchDto? groupBranch;

  AddUpdateGroupBranchModalState(this.groupId, {this.groupBranch});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (groupBranch != null && groupBranch!.id != null) {
      _nameController.text = groupBranch!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
        bloc: context.read<AddUpdateGroupBranchBloc>(),
        listener: (ctx, state) {
          if (state is GroupBranchLoading) {
          } else {
            if (state is GroupBranchAddSuccess) {
              ToastDialog.success("Branch added successfully");
              Navigator.of(context).pop();
            } else if (state is GroupBranchUpdateSuccess) {
              ToastDialog.success("Branch updated successfully");
              Navigator.of(context).pop();
            }
          }
        },
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: TextInputDecoration(labelText: "Branch Name"),
                  controller: _nameController,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter branch name";
                    }
                    return null;
                  },
                ),
                SpacerSize.at(1.5)
              ],
            ),
          ),
        ));
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        if (!_formKey.currentState!.validate()) return;
        FocusScope.of(context).unfocus();

        var branch = GroupBranchDto(
            groupId: groupId,
            name: _nameController.text,
            id: groupBranch?.id,
            active: groupBranch?.active ?? true);

        if (groupBranch != null && groupBranch!.id != null) {
          context
              .read<AddUpdateGroupBranchBloc>()
              .add(UpdateGroupBranch(branch));
        } else {
          context.read<AddUpdateGroupBranchBloc>().add(AddGroupBranch(branch));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      })
    ];
  }

  @override
  String getTitle() {
    return groupBranch == null ? "Add Branch" : "Update Branch";
  }
}
