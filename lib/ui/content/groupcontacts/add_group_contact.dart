import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_contact_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_contact_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';

import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/spacer_size.dart';
import '../../widgets/text_input_decoration.dart';

class AddUpdateGroupContactModelState extends BaseModalRouteState {
  final String groupId;
  final GroupIncidentContactDto? contact;

  AddUpdateGroupContactModelState(this.groupId, {this.contact});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  final phoneNumberMatcher = RegExp(
      r"^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$");

  @override
  void initState() {
    super.initState();
    if (contact != null && contact!.id != null) {
      _firstNameController.text = contact!.firstName;
      _lastNameController.text = contact!.lastName;
      _phoneNumberController.text = contact!.phoneNumber;
      _emailController.text = contact!.email ?? "";
      _designationController.text = contact!.designation ?? "";
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<AddUpdateGroupIncidentContactBloc>(),
      listener: (context, state) {
        if (state is GroupIncidentLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupIncidentErrorState) {
            ToastDialog.error(MessagesConst.internalServerError);
          }
          if (state is ContactAddedSuccessState) {
            ToastDialog.success("Contact added successfully");
            Navigator.of(context).pop();
          }
          if (state is ContactUpdatedSuccessState) {
            ToastDialog.success("Contact updated successfully");
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
                  decoration: TextInputDecoration(labelText: "First Name"),
                  controller: _firstNameController,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter first name";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                  decoration: TextInputDecoration(labelText: "Last Name"),
                  controller: _lastNameController,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter last name";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                  decoration: TextInputDecoration(labelText: "Contact Number"),
                  controller: _phoneNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter contact number";
                    }
                    if (!phoneNumberMatcher.hasMatch(value)) {
                      return "Please enter valid contact number";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                  decoration: TextInputDecoration(labelText: "Email"),
                  controller: _emailController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return null;
                    }
                    if (!EmailValidator.validate(value!)) {
                      return "Please enter valid email";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                decoration: TextInputDecoration(labelText: "Designation"),
                controller: _designationController,
              ),
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
        if (!_formKey.currentState!.validate()) return;
        FocusScope.of(context).unfocus();
        var addContact = GroupIncidentContactDto(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            phoneNumber: _phoneNumberController.text,
            email: _emailController.text,
            designation: _designationController.text,
            id: contact?.id);
        if (contact != null && contact!.id != null) {
          context.read<AddUpdateGroupIncidentContactBloc>().add(
              UpdateGroupIncidentContact(groupId, contact!.id!, addContact));
        } else {
          context
              .read<AddUpdateGroupIncidentContactBloc>()
              .add(AddGroupIncidentContact(groupId, addContact));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return contact == null ? "Add Contact" : "Update Contact";
  }
}
