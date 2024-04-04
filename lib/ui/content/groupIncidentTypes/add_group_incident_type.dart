import 'dart:convert';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/custom_colors.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddUpdateGroupIncidentTypeModelState extends BaseModalRouteState {
  final String groupId;
  final GroupIncidentTypeModel? incidentType;

  AddUpdateGroupIncidentTypeModelState(this.groupId, {this.incidentType});
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  Icon _icon = const Icon(Icons.report);
  Color _dialogPickerColor = const Color(0xFFED3032);

  List<GroupBranchDto> _branches = [];
  List<GroupBranchDto> _selectedBranches = [];

  final multiSelectState = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    if (incidentType != null && incidentType?.id != null) {
      _nameController.text = incidentType!.name;
      _descriptionController.text = incidentType!.description;
      if (incidentType!.iconData != null) {
        _icon = Icon(
          deserializeIcon(jsonDecode(incidentType!.iconData!)),
        );
      }
      _dialogPickerColor = Color(
          int.parse(incidentType!.color.substring(1, 7), radix: 16) +
              0xFF000000);
    }

    context.read<GroupIncidentTypeBloc>().add(GetBranches(groupId, ""));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  _pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(context,
        iconPackModes: [IconPack.material, IconPack.fontAwesomeIcons],
        backgroundColor: AppColor.baseBackground);
    if (icon != null) {
      _icon = Icon(icon);
      setState(() {});
    }
  }

  Future<bool> _colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: _dialogPickerColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) =>
          setState(() => _dialogPickerColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: const Text(
        'Select color',
        style: TextStyle(color: Colors.black),
      ),
      subheading: const Text(
        'Select color shade',
        style: TextStyle(color: Colors.black),
      ),
      wheelSubheading: const Text(
        'Selected color and its shades',
        style: TextStyle(color: Colors.black),
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: const TextStyle(color: Colors.black),
      colorNameTextStyle: const TextStyle(color: Colors.black),
      colorCodeTextStyle: const TextStyle(color: Colors.black),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<GroupIncidentTypeBloc>(),
      listener: (context, GroupIncidentTypeState state) {
        if (state is GroupIncidentTypeLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is AddUpdateGroupIncidentTypeFailedState) {
            ToastDialog.error(
                state.message ?? MessagesConst.internalServerError);
          }
          if (state is AddGroupIncidentTypeSuccessState) {
            ToastDialog.success("Incident Type added successfully");
            Navigator.of(context).pop();
          }
          if (state is UpdateGroupIncidentTypeSuccessState) {
            ToastDialog.success("Incident Type updated successfully");
            Navigator.of(context).pop();
          }
          if (state is GetBranchesSuccessState) {
            setState(() {
              _branches = state.model;
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
              if (incidentType == null)
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
              if (incidentType == null) SpacerSize.at(1.5),
              TextFormField(
                  decoration: TextInputDecoration(labelText: "Name"),
                  controller: _nameController,
                  maxLength: 100,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter name";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              TextFormField(
                  decoration: TextInputDecoration(labelText: "Description"),
                  controller: _descriptionController,
                  maxLength: 300,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  }),
              SpacerSize.at(1.5),
              const Text("Incident Type Icon"),
              SpacerSize.at(1),
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _icon,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    buttonText: "Change",
                    onPressed: () => _pickIcon(),
                    weight: FontWeight.w400,
                  )
                ],
              ),
              SpacerSize.at(1.5),
              const Text("Incident Type Color"),
              SpacerSize.at(1),
              Row(
                children: [
                  Container(
                    color: _dialogPickerColor,
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    buttonText: "Change",
                    onPressed: () async {
                      final Color colorBeforeDialog = _dialogPickerColor;
                      if (!(await _colorPickerDialog())) {
                        setState(() {
                          _dialogPickerColor = colorBeforeDialog;
                        });
                      }
                    },
                    weight: FontWeight.w400,
                  )
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
        var addIncidentType = GroupIncidentTypeModel(
            groupId: groupId,
            name: _nameController.text,
            color: "#${_dialogPickerColor.hex}",
            description: _descriptionController.text,
            iconData: jsonEncode(serializeIcon(_icon.icon!)),
            branchId: incidentType?.branchId);
        if (incidentType != null && incidentType!.id != null) {
          context.read<GroupIncidentTypeBloc>().add(
              UpdateIncidentType(groupId, incidentType!.id!, addIncidentType));
        } else {
          addIncidentType.branches =
              _selectedBranches.map((e) => e.id!).toList();
          context
              .read<GroupIncidentTypeBloc>()
              .add(AddIncidentType(groupId, addIncidentType));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return incidentType == null ? "Add Incident Type" : "Update Incident Type";
  }
}
