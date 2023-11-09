import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/add_question.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/copy_branch_questions.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/view_question.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';

import '../../../data/api/base_api.dart';
import '../../../data/api/group_incident_type_api.dart';
import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';
import '../../widgets/text_input_decoration.dart';

class GroupIncidentTypeQuestionContent extends StatefulWidget
    with FloatingActionMixin, AppBarBranchSelectionMixin {
  final String groupId;
  final String? branchId;
  const GroupIncidentTypeQuestionContent({
    Key? key,
    required this.groupId,
    required this.branchId,
  }) : super(key: key);

  @override
  State<GroupIncidentTypeQuestionContent> createState() =>
      _GroupIncidentTypeQuestionContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(
          stateGenerator: () =>
              AddUpdateGroupIncidentTypeQuestionModelState(groupId));
    })).then((_) {
      context.read<GroupIncidentTypeQuestionBloc>().add(RefreshQuestions());
    });
  }

  @override
  void branchSelection(BuildContext context, String? branchId) {
    context
        .read<GroupIncidentTypeQuestionBloc>()
        .add(BranchChangedEvent(branchId));
  }
}

class _GroupIncidentTypeQuestionContentState
    extends State<GroupIncidentTypeQuestionContent> {
  String? _selectedBranchId;
  String _selectedIncidentTypeId = "";
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];
  final List<GroupIncidentTypeDto> _incidents = [
    GroupIncidentTypeDto(id: "", name: "ALL", description: "", groupId: "")
  ];
  final List<GroupIncidentTypeQuestionDto> _questions = [];

  @override
  void initState() {
    _selectedBranchId = widget.branchId;
    // context
    //     .read<GroupIncidentTypeQuestionBloc>()
    //     .add(GetQuestions(widget.groupId, _searchValue, _selectedBranchId));
    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      controller: _loadingController,
      blockPopOnLoad: true,
      child: BlocListener(
          bloc: context.read<GroupIncidentTypeQuestionBloc>(),
          listener: (context, state) async {
            if (state is GroupIncidentTypeQuestionLoadingState) {
              _loadingController.show();
            } else {
              _loadingController.hide();
              if (state is GetGroupIncidentTypeQuestionsSuccessState) {
                _questions.clear();
                _questions.addAll(state.model
                    .where((element) => element.rootQuestionId == null)
                    .toList());
                _contacts.clear();
                _contacts.addAll(_questions.map((e) {
                  List<AdaptiveContextualItem> contextualItems = [];
                  if (_showMoveUpDownButton(e, "up")) {
                    contextualItems.add(AdaptiveItemButton(
                        "Move Up", const Icon(Icons.arrow_circle_up), () async {
                      context.read<GroupIncidentTypeQuestionBloc>().add(
                          ChangeQuestionOrder(
                              _selectedIncidentTypeId, e.id!, "up"));
                    }));
                  }
                  if (_showMoveUpDownButton(e, "down")) {
                    contextualItems.add(AdaptiveItemButton(
                        "Move Down", const Icon(Icons.arrow_circle_down),
                        () async {
                      context.read<GroupIncidentTypeQuestionBloc>().add(
                          ChangeQuestionOrder(
                              _selectedIncidentTypeId, e.id!, "down"));
                    }));
                  }

                  if (e.questionType == QuestionType.singlePickList) {
                    contextualItems.add(AdaptiveItemButton(
                        "View", const Icon(Icons.view_headline), () async {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return ModalRouteWidget(
                            stateGenerator: () =>
                                ViewGroupIncidentTypeQuestionModelState(
                                  widget.groupId,
                                  e,
                                  e,
                                  previousTree: e.incidentType,
                                ));
                      })).then((_) {
                        context.read<GroupIncidentTypeQuestionBloc>().add(
                            GetQuestions(widget.groupId, "", _selectedBranchId,
                                _selectedIncidentTypeId));
                      });
                    }));
                  }

                  contextualItems.add(AdaptiveItemButton(
                      "Edit", const Icon(Icons.edit), () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return ModalRouteWidget(
                          stateGenerator: () =>
                              AddUpdateGroupIncidentTypeQuestionModelState(
                                  widget.groupId,
                                  questionDto: e));
                    })).then((_) {
                      context.read<GroupIncidentTypeQuestionBloc>().add(
                          GetQuestions(widget.groupId, "", _selectedBranchId,
                              _selectedIncidentTypeId));
                    });
                  }));
                  contextualItems.add(AdaptiveItemButton(
                      "Delete", const Icon(Icons.delete), () async {
                    showConfirmationDialog(
                        context: context,
                        body:
                            "Deleting this record will delete all of its child records as well."
                            "\nAre you sure you want to delete this record?",
                        onPressedOk: () {
                          context
                              .read<GroupIncidentTypeQuestionBloc>()
                              .add(DeleteQuestion(widget.groupId, e.id!));
                        });
                  }));
                  return AdaptiveListItem(
                      "Question: ${e.question}",
                      "Incident Type: ${e.incidentType}"
                          "\nQuestion Type: ${GroupIncidentTypeQuestionDto.getQuestionTypeDisplay(e.questionType)}",
                      const Icon(Icons.question_answer),
                      contextualItems,
                      onPressed: () {});
                }));
                setState(() {});
              }
              if (state is GroupIncidentTypeQuestionFailedState) {
                ToastDialog.error(
                    state.message ?? MessagesConst.internalServerError);
              }
              if (state is GetGroupIncidentTypeQuestionsNotFoundState) {
                _contacts.clear();
                ToastDialog.warning("No records found");
                setState(() {});
              }
              if (state is DeleteGroupIncidentTypeQuestionSuccessState) {
                ToastDialog.success("Record deleted successfully");
                context.read<GroupIncidentTypeQuestionBloc>().add(GetQuestions(
                    widget.groupId,
                    _searchValue,
                    _selectedBranchId,
                    _selectedIncidentTypeId));
              }
              if (state is BranchChangedState) {
                _selectedBranchId = state.branchId;
                _selectedIncidentTypeId = "";
                await _loadIncidentTypesForBranches();
                context.read<GroupIncidentTypeQuestionBloc>().add(GetQuestions(
                    widget.groupId,
                    _searchValue,
                    _selectedBranchId,
                    _selectedIncidentTypeId));
              }
              if (state is RefreshQuestionsState) {
                context.read<GroupIncidentTypeQuestionBloc>().add(GetQuestions(
                    widget.groupId,
                    _searchValue,
                    _selectedBranchId,
                    _selectedIncidentTypeId));
              }
              if (state is ChangeQuestionOrderSuccessState) {
                ToastDialog.success("Record updated successfully");
                context.read<GroupIncidentTypeQuestionBloc>().add(GetQuestions(
                    widget.groupId,
                    _searchValue,
                    _selectedBranchId,
                    _selectedIncidentTypeId));
              }
            }
          },
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12,12,12,0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: DropdownButtonFormField<String>(
                              decoration: TextInputDecoration(
                                  labelText:
                                      "Select incident type to reorder questions"),
                              value: _selectedIncidentTypeId,
                              isExpanded: false,
                              isDense: true,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIncidentTypeId = value ?? "";
                                });
                                context
                                    .read<GroupIncidentTypeQuestionBloc>()
                                    .add(GetQuestions(
                                        widget.groupId,
                                        _searchValue,
                                        _selectedBranchId,
                                        _selectedIncidentTypeId));
                              },
                              items: _incidents.map<DropdownMenuItem<String>>(
                                  (GroupIncidentTypeDto value) {
                                return DropdownMenuItem<String>(
                                  value: value.id,
                                  child: Text(
                                    value.name,
                                  ),
                                );
                              }).toList()),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AppButtonWithIcon(
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (ctx) {
                                return ModalRouteWidget(
                                    stateGenerator: () =>
                                        CopyBranchQuestionsModalState(
                                            widget.groupId,
                                            _selectedBranchId!));
                              })).then((_) {
                                // Inform state to refresh the list
                                context
                                    .read<GroupIncidentTypeQuestionBloc>()
                                    .add(RefreshQuestions());
                              });
                            },
                            buttonText: "Copy From Branch",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: SearchableList(
                        searchHint: "Question",
                        searchIcon: const Icon(Icons.search),
                        onSearchSubmitted: (value) {
                          _searchValue = value;
                          context.read<GroupIncidentTypeQuestionBloc>().add(
                              GetQuestions(widget.groupId, _searchValue,
                                  _selectedBranchId, _selectedIncidentTypeId));
                        },
                        list: _contacts)),
              ])),
    );
  }

  bool _showMoveUpDownButton(GroupIncidentTypeQuestionDto e, String type) {
    if (_selectedIncidentTypeId.isEmpty) return false;
    if (_questions.isEmpty || _questions.length == 1) {
      return false;
    }
    var indexOf = _questions.indexOf(e);
    if (type == "up" && indexOf == 0) return false;
    if (type == "down" && indexOf == (_questions.length - 1)) return false;
    return true;
  }

  _loadIncidentTypesForBranches() async {
    _incidents.clear();
    _incidents.add(GroupIncidentTypeDto(
        id: "", name: "ALL", description: "", groupId: ""));
    _loadingController.show();
    var result =
        await context.read<IGroupIncidentTypeApi>().get("", _selectedBranchId);
    if (result is OkData<List<GroupIncidentTypeDto>>) {
      _incidents.addAll(result.dto);
    }
    _loadingController.hide();
    setState(() {});
  }
}
