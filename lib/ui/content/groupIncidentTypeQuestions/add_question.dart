import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddUpdateGroupIncidentTypeQuestionModelState extends BaseModalRouteState {
  final String groupId;
  final GroupIncidentTypeQuestionDto? parentQuestion;
  final GroupIncidentTypeQuestionDto? questionDto;
  final bool? isYesQuestion;

  AddUpdateGroupIncidentTypeQuestionModelState(this.groupId,
      {this.questionDto, this.parentQuestion, this.isYesQuestion});

  late List<GroupIncidentTypeModel> _incidentTypes = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? _selectedIncidentType;

  @override
  void initState() {
    super.initState();
    if (questionDto != null && questionDto?.id != null) {
      _nameController.text = questionDto!.question;
      _selectedIncidentType = questionDto!.incidentTypeId;
    }
    if (parentQuestion != null) {
      _selectedIncidentType = parentQuestion!.incidentTypeId;
    }
    context.read<GroupIncidentTypeQuestionBloc>().add(GetIncidents(groupId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<GroupIncidentTypeQuestionBloc>(),
      listener: (context, GroupIncidentTypeQuestionState state) {
        if (state is GroupIncidentTypeQuestionLoadingState) {
          showLoader();
        } else {
          hideLoader();
          if (state is GroupIncidentTypeQuestionFailedState) {
            ToastDialog.error(
                state.message ?? MessagesConst.internalServerError);
          }
          if (state is AddGroupIncidentTypeQuestionSuccessState) {
            ToastDialog.success("Question added successfully");
            Navigator.of(context).pop();
          }
          if (state is UpdateGroupIncidentTypeQuestionSuccessState) {
            ToastDialog.success("Question updated successfully");
            Navigator.of(context).pop();
          }
          if (state is GetIncidentTypesSuccessState) {
            setState(() {
              _incidentTypes = state.incidentTypes;
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
              parentQuestion == null
                  ? DropdownButtonFormField<String>(
                      decoration: DropDownInputDecoration(),
                      hint: const Text("Select Incident Type"),
                      value: _selectedIncidentType,
                      onChanged: (value) {
                        setState(() {
                          _selectedIncidentType = value;
                        });
                      },
                      validator: (value) {
                        if (_selectedIncidentType == null) {
                          return "Please select Incident Type";
                        }
                        return null;
                      },
                      items: _incidentTypes.map<DropdownMenuItem<String>>(
                          (GroupIncidentTypeModel value) {
                        return DropdownMenuItem<String>(
                          value: value.id,
                          child: Text(
                            value.name,
                          ),
                        );
                      }).toList())
                  : Container(),
              parentQuestion == null ? SpacerSize.at(1.5) : Container(),
              TextFormField(
                decoration: TextInputDecoration(labelText: "Question"),
                controller: _nameController,
                maxLength: 200,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter question";
                  }
                  return null;
                },
                minLines: 3,
                maxLines: 3,
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
        var question = GroupIncidentTypeQuestionDto(
            groupId: groupId,
            question: _nameController.text,
            incidentTypeId: _selectedIncidentType!,
            isYes: isYesQuestion,
            parentQuestionId: parentQuestion?.id);

        if (questionDto != null && questionDto!.id != null) {
          context
              .read<GroupIncidentTypeQuestionBloc>()
              .add(UpdateQuestion(groupId, questionDto!.id!, question));
        } else {
          context
              .read<GroupIncidentTypeQuestionBloc>()
              .add(AddQuestion(groupId, question));
        }
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return questionDto == null ? "Add Question" : "Update Question";
  }
}
