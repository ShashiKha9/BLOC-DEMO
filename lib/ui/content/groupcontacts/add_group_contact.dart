import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_invite_contact_bloc.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
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
  late List<GroupIncidentTypeModel> _preSelectedIncidents = [];
  final List<GroupIncidentTypeModel> _selectedIncidents = [];
  List<GroupBranchDto> _branches = [];
  List<GroupBranchDto> _selectedBranches = [];
  String _selectedLoginMode = "Phone";
  bool _canCloseChat = false;
  bool _emailAndLoginWithReadOnly = false;

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
      if (contact!.role == 'Admin') {
        _emailAndLoginWithReadOnly = true;
      }
    }
    context.read<AddUpdateGroupInviteContactBloc>().add(GetIncidentTypes(""));
    context.read<AddUpdateGroupInviteContactBloc>().add(GetBranches(groupId));
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
              _incidentList.insert(
                  0,
                  GroupIncidentTypeModel(
                      id: 'all',
                      name: 'All',
                      groupId: _incidentList.first.groupId,
                      description: "",
                      branchId: 'all'));
              if (contact != null &&
                  contact!.incidentTypeList != null &&
                  contact!.incidentTypeList!.isNotEmpty) {
                _preSelectedIncidents = _incidentList
                    .where((e) => contact!.incidentTypeList!.contains(e.id))
                    .toList();
                _selectedIncidents.clear();
                _selectedIncidents.addAll(_preSelectedIncidents);
              }
            });
          }
          if (state is GetBranchesSuccessState) {
            setState(() {
              _branches = state.branches;
              var activeBranches =
                  state.branches.where((e) => e.active).toList();
              if (contact != null && contact!.branchIds != null) {
                _selectedBranches = _branches
                    .where((e) => contact!.branchIds!.contains(e.id))
                    .toList();
              }
              activeBranches.addAll(_selectedBranches
                  .where((element) => !element.active)
                  .toList());
              _branches = activeBranches;
            });
          }
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.start,
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
                  readOnly: _emailAndLoginWithReadOnly,
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
              // _emailController.text.isNotEmpty
              //     ? const Text("Login With")
              //     : Container(),
              // _emailController.text.isNotEmpty
              //     ? SpacerSize.at(0.5)
              //     : Container(),
              _emailController.text.isNotEmpty
                  ? DropdownButtonFormField<String>(
                      decoration: TextInputDecoration(labelText: "Login With"),
                      hint: const Text("Login With"),
                      value: _selectedLoginMode,
                      disabledHint: _emailAndLoginWithReadOnly
                          ? const Text(
                              "Login with change not allowed for admin users.")
                          : null,
                      onChanged: _emailAndLoginWithReadOnly
                          ? null
                          : (value) {
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
                      child: const Text("Allow user to close all incidents"))
                ],
              ),
              if (contact == null || contact!.role != 'Admin')
                SpacerSize.at(1.5),
              if (contact == null || contact!.role != 'Admin')
                const Text("Assign branches to user"),
              if (contact == null || contact!.role != 'Admin') SpacerSize.at(1),
              if (contact == null || contact!.role != 'Admin')
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _branches
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => {
                                    setState(() {
                                      if (_selectedBranches.contains(e)) {
                                        _selectedBranches.remove(e);
                                        _selectedIncidents.removeWhere(
                                            (element) =>
                                                element.branchId == e.id);
                                      } else {
                                        _selectedBranches.add(e);
                                      }
                                    })
                                  },
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _selectedBranches.contains(e)
                                            ? const Icon(Icons.check_box)
                                            : const Icon(Icons
                                                .check_box_outline_blank),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(e.name)
                                      ]),
                                ),
                                SpacerSize.at(1.5),
                                if (_selectedBranches.contains(e))
                                  IncidentTypeSelection(
                                    selectedIncidents: _preSelectedIncidents
                                        .where((element) =>
                                            element.branchId == e.id)
                                        .toList(),
                                    incidentTypes: _incidentList
                                        .where((element) =>
                                            element.id == 'all' ||
                                            element.branchId == e.id)
                                        .toList(),
                                    onSelectionChange:
                                        (List<GroupIncidentTypeModel>
                                            selectedIncidents) {
                                      _selectedIncidents.removeWhere(
                                          (element) =>
                                              element.branchId == e.id);
                                      _selectedIncidents
                                          .addAll(selectedIncidents);
                                    },
                                  ),
                                SpacerSize.at(1.5),
                              ],
                            ))
                        .toList()),
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
        if (_selectedBranches.isEmpty) {
          ToastDialog.error("Please select at least one branch.");
          return;
        }
        var formattedMobileNumber = await PhoneNumberUtility.parseToE164Format(
            phoneNumber: _phoneNumberController.text);
        _selectedIncidents.removeWhere((element) => element.id == 'all');
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
            incidentTypeList: [
              ...{..._selectedIncidents.map((e) => e.id!).toList()}
            ],
            branchIds: _selectedBranches.map((e) => e.id!).toList());
        if (contact != null && contact!.id != null) {
          if (contact!.role == "Admin") {
            addContact.email = contact!.email;
            addContact.loginWith = contact!.loginWith;
          }
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

class IncidentTypeSelection extends StatefulWidget {
  final List<GroupIncidentTypeModel> incidentTypes;
  final Function(List<GroupIncidentTypeModel>) onSelectionChange;
  final List<GroupIncidentTypeModel>? selectedIncidents;
  final bool? preSelectAll;

  const IncidentTypeSelection(
      {Key? key,
      required this.incidentTypes,
      required this.onSelectionChange,
      this.selectedIncidents,
      this.preSelectAll})
      : super(key: key);

  @override
  _IncidentTypeSelectionState createState() => _IncidentTypeSelectionState();
}

class _IncidentTypeSelectionState extends State<IncidentTypeSelection> {
  List<GroupIncidentTypeModel> _selectedIncidents = [];

  @override
  void initState() {
    super.initState();
    _selectedIncidents = widget.selectedIncidents ?? [];
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _handleCheckboxSelection();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      margin: const EdgeInsets.only(left: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select incident types to get notified:"),
          const SizedBox(
            height: 5,
          ),
          Wrap(
            spacing: 20,
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: widget.incidentTypes
                .map((e) => InkWell(
                      onTap: () {
                        setState(() {
                          if (e.id == 'all') {
                            if (_selectedIncidents.contains(e)) {
                              _selectedIncidents.clear();
                            } else {
                              _selectedIncidents =
                                  widget.incidentTypes.toList();
                              _selectedIncidents.add(e);
                            }
                          } else {
                            _selectedIncidents.contains(e)
                                ? _selectedIncidents.remove(e)
                                : _selectedIncidents.add(e);
                          }
                          _handleCheckboxSelection();
                          widget.onSelectionChange(_selectedIncidents);
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _selectedIncidents.contains(e)
                              ? const Icon(Icons.check_box)
                              : const Icon(Icons.check_box_outline_blank),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(e.name)
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  _handleCheckboxSelection() {
    setState(() {
      if (_selectedIncidents.where((element) => element.id != 'all').length ==
          widget.incidentTypes.length - 1) {
        _selectedIncidents.add(
            widget.incidentTypes.firstWhere((element) => element.id == 'all'));
      } else {
        _selectedIncidents.removeWhere((element) => element.id == 'all');
      }
    });
  }
}
