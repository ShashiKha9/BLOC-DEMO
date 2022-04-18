import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_domain_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/constants/validation_messages.dart';
import 'package:rescu_organization_portal/data/models/group_domain_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddDomainModelState extends BaseModalRouteState {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _domainController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<AddGroupDomainBloc>(),
      listener: (context, state) {
        if (state is GroupDomainLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is AddGroupDomainErrorState) {
            ToastDialog.error(state.message);
          }
          if (state is GroupDomainUnknownErrorState) {
            ToastDialog.error(MessagesConst.internalServerError);
          }
          if (state is AddGroupDomainSuccessState) {
            Navigator.of(context).pop(true);
            ToastDialog.success(MessagesConst.groupUserCreateSuccess);
          }
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  decoration: TextInputDecoration(labelText: "Domain"),
                  controller: _domainController,
                  focusNode: _focusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ValidationMessagesConst.loginEmailRequired;
                    }
                    if (!RegExp(
                            '^(?!-)[A-Za-z0-9-]+([\\-\\.]{1}[a-z0-9]+)*\\.[A-Za-z]{2,6}')
                        .hasMatch(value)) {
                      return "Enter valid domain";
                    }
                    return null;
                  }),
            ),
            SpacerSize.at(1.5),
          ],
        ),
      ),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        if (!_formKey.currentState!.validate()) return;
        FocusScope.of(context).unfocus();

        context.read<AddGroupDomainBloc>().add(AddGroupDomain(GroupDomainModel(
            id: "", domain: _domainController.text.trim(), groupId: "")));
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return "Add Domain";
  }
}
