import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_incident_type_question_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_widgets.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/add_question.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';

class ViewGroupIncidentTypeQuestionModelState extends BaseModalRouteState {
  final String groupId;
  GroupIncidentTypeQuestionDto questionDto;
  GroupIncidentTypeQuestionDto rootQuestion;
  final String? previousTree;
  ViewGroupIncidentTypeQuestionModelState(
      this.groupId, this.questionDto, this.rootQuestion,
      {this.previousTree});

  @override
  void initState() {
    super.initState();
    context
        .read<GroupIncidentTypeQuestionBloc>()
        .add(GetQuestion(questionDto.id!));
  }

  @override
  Widget content(BuildContext context) {
    return BlocListener(
      bloc: context.read<GroupIncidentTypeQuestionBloc>(),
      listener: (context, state) async {
        if (state is GroupIncidentTypeQuestionLoadingState) {
        } else {
          if (state is GetQuestionSuccessState) {
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              setState(() {
                questionDto = state.questionDto;
              });
            }
          }
          if (state is DeleteGroupIncidentTypeQuestionSuccessState) {
            context
                .read<GroupIncidentTypeQuestionBloc>()
                .add(GetQuestion(questionDto.id!));
          }
        }
      },
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: questionDto.options != null &&
                      questionDto.options!.isNotEmpty
                  ? [
                      const Text(
                        "Single Picklist Options",
                        style: TextStyle(fontSize: 20),
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SpacerSize.at(2.5),
                      ...questionDto.options!
                          .map((e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.optionText,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const Divider(
                                    thickness: 2,
                                  ),
                                  e.childQuestions != null &&
                                          e.childQuestions!.isNotEmpty
                                      ? AdaptiveListTile(
                                          item: _getQuestionListItem(
                                              e.childQuestions!.first))
                                      : AppButtonWithIcon(
                                          icon: const Icon(Icons.add),
                                          onPressed: () async {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) {
                                              return ModalRouteWidget(
                                                  stateGenerator: () =>
                                                      AddUpdateGroupIncidentTypeQuestionModelState(
                                                          groupId,
                                                          parentOption: e,
                                                          rootQuestion:
                                                              rootQuestion));
                                            })).then((_) {
                                              context
                                                  .read<
                                                      GroupIncidentTypeQuestionBloc>()
                                                  .add(GetQuestion(
                                                      questionDto.id!));
                                            });
                                          },
                                          buttonText: "Add Question",
                                        ),
                                  SpacerSize.at(1.5)
                                ],
                              ))
                          .toList(),
                    ]
                  : [Text(questionDto.getQuestionTypeString())])),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }

  @override
  String getTitle() {
    return (previousTree == null ? "" : previousTree! + " / ") +
        _getTrimmedTitle();
  }

  String _getTrimmedTitle() {
    String title = questionDto.question;
    if (questionDto.question.split(" ").length > 4) {
      var map = questionDto.question.split(" ");
      title = "${map[0]} ${map[1]} ${map[2]} ${map[3]}...";
    }
    return title;
  }

  AdaptiveListItem _getQuestionListItem(GroupIncidentTypeQuestionDto e) {
    List<AdaptiveContextualItem> contextualItems = [];
    if (e.questionType == QuestionType.singlePickList) {
      contextualItems.add(
          AdaptiveItemButton("View", const Icon(Icons.view_headline), () async {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return ModalRouteWidget(
              stateGenerator: () => ViewGroupIncidentTypeQuestionModelState(
                  groupId, e, rootQuestion,
                  previousTree:
                      (previousTree == null ? "" : previousTree! + " / ") +
                          _getTrimmedTitle()));
        })).then((_) {
          context
              .read<GroupIncidentTypeQuestionBloc>()
              .add(GetQuestion(questionDto.id!));
        });
      }));
    }
    contextualItems
        .add(AdaptiveItemButton("Edit", const Icon(Icons.edit), () async {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return ModalRouteWidget(
            stateGenerator: () => AddUpdateGroupIncidentTypeQuestionModelState(
                groupId,
                questionDto: e,
                rootQuestion: rootQuestion));
      })).then((_) {
        context
            .read<GroupIncidentTypeQuestionBloc>()
            .add(GetQuestion(questionDto.id!));
      });
    }));

    contextualItems
        .add(AdaptiveItemButton("Delete", const Icon(Icons.delete), () async {
      showConfirmationDialog(
          context: context,
          body:
              "Deleting this record will delete all of its child records as well."
              "\nAre you sure you want to delete this record?",
          onPressedOk: () {
            context
                .read<GroupIncidentTypeQuestionBloc>()
                .add(DeleteQuestion(groupId, e.id!));
          });
    }));
    return AdaptiveListItem(
        "Question: ${e.question}",
        "Incident Type: ${e.incidentType}"
            "\nQuestion Type: ${GroupIncidentTypeQuestionDto.getQuestionTypeDisplay(e.questionType)}",
        const Icon(Icons.question_answer),
        contextualItems,
        onPressed: () {});
  }
}
