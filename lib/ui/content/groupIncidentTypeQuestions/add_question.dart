import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_option_dto.dart';
import 'package:rescu_organization_portal/data/models/group_incident_type_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class AddUpdateGroupIncidentTypeQuestionModelState extends BaseModalRouteState {
  final String groupId;
  final GroupIncidentTypeQuestionDto? rootQuestion;
  final GroupIncidentTypeQuestionOptionDto? parentOption;
  final GroupIncidentTypeQuestionDto? questionDto;

  AddUpdateGroupIncidentTypeQuestionModelState(this.groupId,
      {this.questionDto, this.rootQuestion, this.parentOption});

  late List<GroupIncidentTypeModel> _incidentTypes = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? _selectedIncidentType;

  final List<QuestionType> _questionTypes = [
    QuestionType.singlePickList,
    QuestionType.multiPickList,
    QuestionType.text
  ];

  QuestionType? _selectedQuestionType;

  final List<GroupIncidentTypeQuestionOptionDto> _options = [
    GroupIncidentTypeQuestionOptionDto(optionText: '')
  ];

  @override
  void initState() {
    super.initState();
    if (questionDto != null && questionDto?.id != null) {
      _nameController.text = questionDto!.question;
      _selectedIncidentType = questionDto!.incidentTypeId;
      _selectedQuestionType = questionDto!.questionType;
      _options.clear();
      _options.addAll(questionDto!.options!);

      if (_options.isEmpty) {
        _options.add(GroupIncidentTypeQuestionOptionDto(optionText: ''));
      }
    }
    if (rootQuestion != null) {
      _selectedIncidentType = rootQuestion!.incidentTypeId;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rootQuestion == null
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
                rootQuestion == null ? SpacerSize.at(1.5) : Container(),
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
                SpacerSize.at(1.5),
                DropdownButtonFormField<QuestionType>(
                    decoration: DropDownInputDecoration(),
                    hint: const Text("Select Question Type"),
                    value: _selectedQuestionType,
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestionType = value;
                      });
                    },
                    validator: (value) {
                      if (_selectedQuestionType == null) {
                        return "Please select Question Type";
                      }
                      return null;
                    },
                    items: _questionTypes.map<DropdownMenuItem<QuestionType>>(
                        (QuestionType value) {
                      return DropdownMenuItem<QuestionType>(
                        value: value,
                        child: Text(
                          GroupIncidentTypeQuestionDto.getQuestionTypeDisplay(
                              value),
                        ),
                      );
                    }).toList()),
                SpacerSize.at(1.5),
                if (_selectedQuestionType != null &&
                    _selectedQuestionType != QuestionType.text)
                  ...(_options.asMap().map((i, e) => MapEntry(
                      i,
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DynamicTextField(
                                  key: UniqueKey(),
                                  initialValue: e.optionText,
                                  onChanged: (value) {
                                    _options[i].optionText = value;
                                  },
                                ),
                              ),
                              SpacerSize.widthAt(1.5),
                              _textfieldBtn(i)
                            ],
                          ),
                          SpacerSize.at(1.5)
                        ],
                      )))).values.toList()
              ],
            ),
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

        if (_selectedQuestionType != QuestionType.text &&
            _options.length == 1) {
          ToastDialog.error("Please add atleast 2 options");
          return;
        }

        FocusScope.of(context).unfocus();
        var question = GroupIncidentTypeQuestionDto(
            groupId: groupId,
            question: _nameController.text,
            incidentTypeId: _selectedIncidentType!,
            questionType: _selectedQuestionType!,
            rootQuestionId: rootQuestion?.id,
            parentOptionId: parentOption?.id,
            options: _options);

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

  Widget _textfieldBtn(int index) {
    bool isLast = index == _options.length - 1;

    return InkWell(
      onTap: () => setState(
        () => isLast
            ? _options.add(GroupIncidentTypeQuestionOptionDto(optionText: ''))
            : _options.removeAt(index),
      ),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isLast ? Colors.green : Colors.red,
        ),
        child: Icon(
          isLast ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DynamicTextField extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onChanged;

  const DynamicTextField({Key? key, this.initialValue, required this.onChanged})
      : super(key: key);

  @override
  _DynamicTextFieldState createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  late final TextEditingController _optionController;

  @override
  void initState() {
    _optionController = TextEditingController(text: widget.initialValue ?? "");
    super.initState();
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: TextInputDecoration(labelText: "Option"),
      controller: _optionController,
      onChanged: (value) {
        widget.onChanged(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter option";
        }
        return null;
      },
    );
  }
}
