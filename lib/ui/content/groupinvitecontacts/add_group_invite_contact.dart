import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/constants/fleet_user_roles.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import '../../../data/blocs/group_invite_contact_bloc.dart';
import '../../../data/dto/group_invite_contact_dto.dart';
import '../../../data/helpers/phone_number_validator.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/spacer_size.dart';
import '../../widgets/text_input_decoration.dart';

class AddUpdateGroupInviteContactModelState extends BaseModalRouteState {
  final String groupId;
  final GroupInviteContactDto? contact;

  AddUpdateGroupInviteContactModelState(this.groupId, {this.contact});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _validMobileNumber = false;
  String _selectedLoginMode = "Phone";
  bool _canCloseChat = false;
  List<GroupBranchDto> _branches = [];
  List<GroupBranchDto> _selectedBranches = [];
  final multiSelectState = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    if (contact != null && contact!.id != null) {
      _firstNameController.text = contact!.firstName;
      _lastNameController.text = contact!.lastName;
      _phoneNumberController.text = contact!.phoneNumber.replaceAll('+1', "");
      _emailController.text = contact!.email ?? "";
      _selectedLoginMode = contact!.loginWith ?? "Phone";
      _canCloseChat = contact!.canCloseChat ?? false;
      _validateContactNumber(contact!.phoneNumber);
    }
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
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<AddUpdateGroupInviteContactBloc>(),
      listener: (context, GroupInviteContactState state) {
        if (state is GroupInviteContactLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupInviteContactErrorState) {
            ToastDialog.error(state.error ?? MessagesConst.internalServerError);
          }
          if (state is ContactAddedSuccessState) {
            ToastDialog.success("Invitee added successfully");
            Navigator.of(context).pop();
          }
          if (state is ContactUpdatedSuccessState) {
            ToastDialog.success("Invitee updated successfully");
            Navigator.of(context).pop();
          }
          if (state is GetBranchesSuccessState) {
            if (state.branches.isNotEmpty) {
              setState(() {
                _branches = state.branches;
                if (contact != null && contact!.id != null) {
                  _selectedBranches = _branches
                      .where(
                          (element) => contact!.branchIds!.contains(element.id))
                      .toList();
                }
              });
              // Wait for build to complete
              Future.delayed(Duration.zero, () {
                multiSelectState.currentState!
                    .didChange(_selectedBranches.map((e) => e.id!).toList());
              });
            }
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
              buildMultiSelectFormField(
                context: context,
                formKey: multiSelectState,
                showSelectAll: true,
                items: _branches
                    .map((e) => {
                          "display": e.name,
                          "value": e.id.toString(),
                        })
                    .toList(),
                onSaved: (value) {
                  if (value == null) return;
                  _selectedBranches = _branches
                      .where((element) => value.contains(element.id))
                      .toList();
                },
                title: "Select Branches",
                initialValue:
                    _selectedBranches.map((e) => e.id.toString()).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select branches";
                  }
                  return null;
                },
              ),
              SpacerSize.at(1.5),
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
                },
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
            email: _emailController.text,
            loginWith: _selectedLoginMode,
            id: contact?.id,
            isActive: contact?.isActive ?? true,
            role: FleetUserRoles.fleet,
            canCloseChat: _canCloseChat,
            branchIds: _selectedBranches.map((e) => e.id!).toList());
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
    return contact == null ? "Add Invitee" : "Update Invitee";
  }
}
