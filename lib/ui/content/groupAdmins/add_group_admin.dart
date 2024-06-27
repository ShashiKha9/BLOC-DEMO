import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_invite_contact_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';

import '../../../data/blocs/group_admins_bloc.dart';
import '../../../data/dto/group_branch_dto.dart';
import '../../../data/helpers/phone_number_validator.dart';
import '../../../data/models/group_incident_type_model.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/spacer_size.dart';
import '../../widgets/text_input_decoration.dart';
import '../groupcontacts/add_group_contact.dart';

class AddUpdateGroupAdminModelState extends BaseModalRouteState {
  final String groupId;
  final GroupInviteContactDto? contact;

  AddUpdateGroupAdminModelState(this.groupId, {this.contact});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _validMobileNumber = false;
  List<GroupIncidentTypeModel> _incidentList = [];
  //List<GroupIncidentTypeModel> _preSelectedIncidents = [];
  final List<GroupIncidentTypeModel> _selectedIncidents = [];
  List<GroupBranchDto> _branches = [];
  List<GroupBranchDto> _selectedBranches = [];

  @override
  void initState() {
    super.initState();
    if (contact != null && contact!.id != null) {
      _firstNameController.text = contact!.firstName;
      _lastNameController.text = contact!.lastName;
      _phoneNumberController.text = contact!.phoneNumber.replaceAll("+1", "");
      _emailController.text = contact!.email ?? "";
      _validateContactNumber(contact!.phoneNumber);
    }
    context.read<AddUpdateGroupAdminBloc>().add(GetIncidentTypes(""));
    context.read<AddUpdateGroupAdminBloc>().add(GetBranches(groupId));
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
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<AddUpdateGroupAdminBloc>(),
      listener: (context, state) {
        if (state is GroupAdminsLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupAdminsErrorState) {
            ToastDialog.error(state.error ?? MessagesConst.internalServerError);
          }
          if (state is AdminAddedSuccessState) {
            ToastDialog.success("Admin added successfully");
            Navigator.of(context).pop();
          }
          if (state is AdminUpdatedSuccessState) {
            ToastDialog.success("Admin updated successfully");
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
                      specialDispatch: _incidentList.first.specialDispatch,
                      description: "",
                      branchId: 'all',
                      color: ""));
              if (contact != null &&
                  contact!.incidentTypeList != null &&
                  contact!.incidentTypeList!.isNotEmpty) {
                // _preSelectedIncidents = _incidentList
                //     .where((e) => contact!.incidentTypeList!.contains(e.id))
                //     .toList();
                _selectedIncidents.clear();
                _selectedIncidents.addAll(_incidentList
                    .where((e) => contact!.incidentTypeList!.contains(e.id))
                    .toList());
              } else {
                //_preSelectedIncidents = _incidentList;
                _selectedIncidents.clear();
                _selectedIncidents.addAll(_incidentList.toList());
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
              } else {
                _selectedBranches = activeBranches.toList();
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
                  readOnly: contact != null && contact!.id != null,
                  onTap: () {
                    if (contact != null && contact!.id != null) {
                      ToastDialog.error(
                          "Email cannot be changed. It is used to log into Group Portal & Rescu Ops.");
                    }
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Please enter email";
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
              SpacerSize.at(0.5),
              contact != null && contact!.id != null
                  ? const SizedBox(
                      height: 0,
                    )
                  : const Text(
                      "This Email should be used to log into Group Portal & Rescu Ops. User will receive the credentials on the email.",
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
              SpacerSize.at(1.5),
              const Text("Assign branches to user"),
              SpacerSize.at(1),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _selectedBranches.contains(e)
                                          ? const Icon(Icons.check_box)
                                          : const Icon(
                                              Icons.check_box_outline_blank),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(e.name)
                                    ]),
                              ),
                              SpacerSize.at(1.5),
                              if (_selectedBranches.contains(e))
                                IncidentTypeSelection(
                                  selectedIncidents: _selectedIncidents
                                      .where(
                                          (element) => element.branchId == e.id)
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
                                        (element) => element.branchId == e.id);
                                    _selectedIncidents
                                        .addAll(selectedIncidents);
                                  },
                                ),
                              SpacerSize.at(1.5),
                            ],
                          ))
                      .toList())
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
            isActive: contact?.isActive ?? true,
            role: FleetUserRoles.admin,
            email: _emailController.text,
            designation: null,
            loginWith: "Email",
            id: contact?.id,
            canCloseChat: true,
            incidentTypeList: [
              ...{
                ..._selectedIncidents
                    .where((e) => e.id != 'all')
                    .map((e) => e.id!)
                    .toList()
              }
            ],
            branchIds: _selectedBranches.map((e) => e.id!).toList());
        if (contact != null && contact!.id != null) {
          context
              .read<AddUpdateGroupAdminBloc>()
              .add(UpdateGroupAdmin(groupId, contact!.id!, addContact));
        } else {
          context
              .read<AddUpdateGroupAdminBloc>()
              .add(AddGroupAdmin(groupId, addContact));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return contact == null ? "Add Admin" : "Update Admin";
  }
}
