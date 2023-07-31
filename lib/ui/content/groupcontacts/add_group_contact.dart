import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_invite_contact_bloc.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_invite_contact_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';

import '../../../data/helpers/phone_number_validator.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/spacer_size.dart';
import '../../widgets/text_input_decoration.dart';

class AddUpdateGroupContactModelState extends BaseModalRouteState {
  final String groupId;
  final GroupInviteContactDto? contact;

  AddUpdateGroupContactModelState(this.groupId, {this.contact});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  bool _validMobileNumber = false;
  late List<GroupIncidentTypeModel> _incidentList = [];
  late List<GroupIncidentTypeModel> _selectedIncidents = [];
  String _selectedLoginMode = "Phone";
  bool _canCloseChat = false;

  @override
  void initState() {
    super.initState();
    if (contact != null && contact!.id != null) {
      _firstNameController.text = contact!.firstName;
      _lastNameController.text = contact!.lastName;
      _phoneNumberController.text = contact!.phoneNumber.replaceAll("+1", "");
      _emailController.text = contact!.email ?? "";
      _designationController.text = contact!.designation ?? "";
      _canCloseChat = contact!.canCloseChat ?? false;
      _validateContactNumber(contact!.phoneNumber);
      _selectedLoginMode = contact!.loginWith ?? "Phone";
    }
    context.read<AddUpdateGroupInviteContactBloc>().add(GetIncidentTypes(""));
  }

  _validateContactNumber(String number) async {
    _validMobileNumber =
        await PhoneNumberUtility.validatePhoneNumber(phoneNumber: number);
    setState(() {});
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
      bloc: context.read<AddUpdateGroupInviteContactBloc>(),
      listener: (context, state) {
        if (state is GroupInviteContactLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupInviteContactErrorState) {
            ToastDialog.error(state.error ?? MessagesConst.internalServerError);
          }
          if (state is ContactAddedSuccessState) {
            ToastDialog.success("Contact added successfully");
            Navigator.of(context).pop();
          }
          if (state is ContactUpdatedSuccessState) {
            ToastDialog.success("Contact updated successfully");
            Navigator.of(context).pop();
          }
          if (state is GetIncidentTypeSuccessState) {
            setState(() {
              _incidentList = state.model;
              if (contact != null &&
                  contact!.incidentTypeList != null &&
                  contact!.incidentTypeList!.isNotEmpty) {
                _selectedIncidents = _incidentList
                    .where((e) => contact!.incidentTypeList!.contains(e.id))
                    .toList();
              }
            });
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

                  if (!_validMobileNumber) {
                    return "Please enter valid contact number";
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    _validateContactNumber(value);
                  }
                },
              ),
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
                  },
                  onChanged: (value) {
                    if (EmailValidator.validate(value)) {
                      setState(() {});
                    }
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                decoration: TextInputDecoration(labelText: "Designation"),
                controller: _designationController,
              ),
              _emailController.text.isNotEmpty
                  ? SpacerSize.at(1.5)
                  : Container(),
              _emailController.text.isNotEmpty
                  ? const Text("Login With")
                  : Container(),
              _emailController.text.isNotEmpty
                  ? SpacerSize.at(0.5)
                  : Container(),
              _emailController.text.isNotEmpty
                  ? DropdownButtonFormField<String>(
                      decoration: DropDownInputDecoration(),
                      hint: const Text("Login With"),
                      value: _selectedLoginMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedLoginMode = value ?? "Phone";
                        });
                      },
                      validator: (value) {
                        return null;
                      },
                      items: const [
                          DropdownMenuItem<String>(
                            value: "Phone",
                            child: Text("Phone"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Email",
                            child: Text("Email"),
                          )
                        ])
                  : Container(),
              SpacerSize.at(1.5),
              Row(
                children: [
                  Checkbox(
                      value: _canCloseChat,
                      onChanged: (value) {
                        setState(() {
                          _canCloseChat = value ?? false;
                        });
                      }),
                  InkWell(
                      onTap: () {
                        setState(() {
                          _canCloseChat = !_canCloseChat;
                        });
                      },
                      child: const Text("Can close incident"))
                ],
              ),
              SpacerSize.at(1.5),
              const Text("Select Incident Types"),
              SpacerSize.at(0.5),
              Expanded(
                  child: BlocListener(
                      bloc: context.read<AddUpdateGroupInviteContactBloc>(),
                      listener: ((context, state) => {}),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: TextInputDecoration(
                                hintText: "Search by name",
                                suffixIcon: const Icon(Icons.search),
                              ),
                              onSubmitted: (value) {
                                context
                                    .read<AddUpdateGroupInviteContactBloc>()
                                    .add(GetIncidentTypes(value));
                              },
                              onChanged: (value) {
                                context
                                    .read<AddUpdateGroupInviteContactBloc>()
                                    .add(GetIncidentTypes(value));
                              },
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                                child: ListView.builder(
                                    itemCount: _incidentList.length,
                                    itemBuilder: (context, index) => ListTile(
                                          leading: _selectedIncidents.contains(
                                                  _incidentList[index])
                                              ? const Icon(Icons.check_box)
                                              : const Icon(Icons
                                                  .check_box_outline_blank),
                                          title:
                                              Text(_incidentList[index].name),
                                          onTap: () => {
                                            setState(() {
                                              _selectedIncidents.contains(
                                                      _incidentList[index])
                                                  ? _selectedIncidents.remove(
                                                      _incidentList[index])
                                                  : _selectedIncidents.add(
                                                      _incidentList[index]);
                                            })
                                          },
                                        )))
                          ],
                        ),
                      )))
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
        var formattedMobileNumber = await PhoneNumberUtility.parseToE164Format(
            phoneNumber: _phoneNumberController.text);
        var addContact = GroupInviteContactDto(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            phoneNumber: formattedMobileNumber,
            isActive: true,
            role: FleetUserRoles.contact,
            email: _emailController.text,
            designation: _designationController.text,
            loginWith: _selectedLoginMode,
            id: contact?.id,
            canCloseChat: _canCloseChat,
            incidentTypeList: _selectedIncidents.map((e) => e.id!).toList());
        if (contact != null && contact!.id != null) {
          context
              .read<AddUpdateGroupInviteContactBloc>()
              .add(UpdateGroupInviteContact(groupId, contact!.id!, addContact));
        } else {
          context
              .read<AddUpdateGroupInviteContactBloc>()
              .add(AddGroupInviteContact(groupId, addContact));
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
