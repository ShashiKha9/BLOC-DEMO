import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/data/constants/validation_messages.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddUserEmailModelState extends BaseModalRouteState {
  final TextEditingController _emailController = TextEditingController();
  List<String> _values = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: TextInputDecoration(
              labelText: "Email", hintText: "Hit enter to submit field"),
          controller: _emailController,
          focusNode: _focusNode,
          onFieldSubmitted: (value) async {
            if (value.isEmpty) {
              ToastDialog.error(ValidationMessagesConst.emailRequired);
              return;
            }
            if (EmailValidator.validate(value)) {
              _values.add(value);
            } else {
              ToastDialog.error(ValidationMessagesConst.emailInvalid);
              return;
            }

            setState(() {
              _values = _values;
              _emailController.clear();
              _focusNode.requestFocus();
            });
          },
        ),
        SpacerSize.at(1.5),
        buildChips(),
      ],
    );
  }

  Widget buildChips() {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: _values.map((v) {
        return InputChip(
          padding: const EdgeInsets.all(10),
          label: Text(v, overflow: TextOverflow.ellipsis),
          labelStyle: const TextStyle(fontSize: 20, color: Colors.white),
          avatar: const Icon(Icons.email_rounded),
          onDeleted: () {
            setState(() {
              _values.remove(v);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("Add", const Icon(Icons.save), () async {
        FocusScope.of(context).unfocus();
        if (_values.isEmpty) {
          ToastDialog.error(
              ValidationMessagesConst.couponEmailOrMobileListInvalid);
          return;
        }
        Navigator.of(context).pop(_values);
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return "Add User(s) Email";
  }
}
