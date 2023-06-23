import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/add_question.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/view_question.dart';

import '../../../data/constants/messages.dart';
import '../../adaptive_items.dart';
import '../../adaptive_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';

class GroupIncidentTypeQuestionContent extends StatefulWidget
    with FloatingActionMixin {
  final String groupId;
  const GroupIncidentTypeQuestionContent({
    Key? key,
    required this.groupId,
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
      context
          .read<GroupIncidentTypeQuestionBloc>()
          .add(GetQuestions(groupId, ""));
    });
  }
}

class _GroupIncidentTypeQuestionContentState
    extends State<GroupIncidentTypeQuestionContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _contacts = [];

  @override
  void initState() {
    context
        .read<GroupIncidentTypeQuestionBloc>()
        .add(GetQuestions(widget.groupId, _searchValue));
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
        listener: (context, state) {
          if (state is GroupIncidentTypeQuestionLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();
            if (state is GetGroupIncidentTypeQuestionsSuccessState) {
              _contacts.clear();
              _contacts.addAll(state.model
                  .where((element) => element.rootQuestionId == null)
                  .map((e) {
                List<AdaptiveContextualItem> contextualItems = [];
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
                      context
                          .read<GroupIncidentTypeQuestionBloc>()
                          .add(GetQuestions(widget.groupId, ""));
                    });
                  }));
                }

                contextualItems.add(AdaptiveItemButton(
                    "Edit", const Icon(Icons.edit), () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ModalRouteWidget(
                        stateGenerator: () =>
                            AddUpdateGroupIncidentTypeQuestionModelState(
                                widget.groupId,
                                questionDto: e));
                  })).then((_) {
                    context
                        .read<GroupIncidentTypeQuestionBloc>()
                        .add(GetQuestions(widget.groupId, ""));
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
              ToastDialog.error(MessagesConst.internalServerError);
            }
            if (state is GetGroupIncidentTypeQuestionsNotFoundState) {
              _contacts.clear();
              ToastDialog.warning("No records found");
              setState(() {});
            }
            if (state is DeleteGroupIncidentTypeQuestionSuccessState) {
              ToastDialog.success("Record deleted successfully");
              context
                  .read<GroupIncidentTypeQuestionBloc>()
                  .add(GetQuestions(widget.groupId, _searchValue));
            }
          }
        },
        child: SearchableList(
            searchHint: "Question and Incident Type",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context
                  .read<GroupIncidentTypeQuestionBloc>()
                  .add(GetQuestions(widget.groupId, _searchValue));
            },
            list: _contacts),
      ),
    );
  }
}
