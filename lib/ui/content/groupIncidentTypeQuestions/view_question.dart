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
  final String? previousTree;
  ViewGroupIncidentTypeQuestionModelState(this.groupId, this.questionDto,
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
            children: [
              const Text(
                "Question on Yes Response",
                style: TextStyle(fontSize: 18),
              ),
              const Divider(
                thickness: 2,
              ),
              _getChildQuestion(true) != null
                  ? AdaptiveListTile(
                      item: _getQuestionListItem(_getChildQuestion(true)!))
                  : AppButtonWithIcon(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return ModalRouteWidget(
                              stateGenerator: () =>
                                  AddUpdateGroupIncidentTypeQuestionModelState(
                                      groupId,
                                      parentQuestion: questionDto,
                                      isYesQuestion: true));
                        })).then((_) {
                          context
                              .read<GroupIncidentTypeQuestionBloc>()
                              .add(GetQuestions(groupId, ""));
                        });
                      },
                      buttonText: "Add Question",
                    ),
              SpacerSize.at(1.5),
              const Text(
                "Question on No Response",
                style: TextStyle(fontSize: 18),
              ),
              const Divider(
                thickness: 2,
              ),
              _getChildQuestion(false) != null
                  ? AdaptiveListTile(
                      item: _getQuestionListItem(_getChildQuestion(false)!))
                  : AppButtonWithIcon(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return ModalRouteWidget(
                              stateGenerator: () =>
                                  AddUpdateGroupIncidentTypeQuestionModelState(
                                      groupId,
                                      parentQuestion: questionDto,
                                      isYesQuestion: false));
                        })).then((_) {
                          context
                              .read<GroupIncidentTypeQuestionBloc>()
                              .add(GetQuestion(questionDto.id!));
                        });
                      },
                      buttonText: "Add Question",
                    ),
            ],
          )),
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

  AdaptiveListItem _getQuestionListItem(e) {
    List<AdaptiveContextualItem> contextualItems = [];
    contextualItems.add(
        AdaptiveItemButton("View", const Icon(Icons.view_headline), () async {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return ModalRouteWidget(
            stateGenerator: () => ViewGroupIncidentTypeQuestionModelState(
                groupId, e,
                previousTree:
                    (previousTree == null ? "" : previousTree! + " / ") +
                        _getTrimmedTitle()));
      })).then((_) {
        context
            .read<GroupIncidentTypeQuestionBloc>()
            .add(GetQuestion(questionDto.id!));
      });
    }));
    contextualItems
        .add(AdaptiveItemButton("Edit", const Icon(Icons.edit), () async {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return ModalRouteWidget(
            stateGenerator: () => AddUpdateGroupIncidentTypeQuestionModelState(
                groupId,
                questionDto: e,
                parentQuestion: questionDto,
                isYesQuestion: e.isYes));
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
          body: "Are you sure you want to delete this record?",
          onPressedOk: () {
            context
                .read<GroupIncidentTypeQuestionBloc>()
                .add(DeleteQuestion(groupId, e.id!));
          });
    }));
    return AdaptiveListItem(
        "Question: ${e.question}",
        "Incident Type: ${e.incidentType}",
        const Icon(Icons.question_answer),
        contextualItems,
        onPressed: () {});
  }

  GroupIncidentTypeQuestionDto? _getChildQuestion(bool isYes) {
    return (questionDto.childQuestions
                ?.where((element) => element.isYes == isYes)
                .isNotEmpty ??
            false)
        ? questionDto.childQuestions
            ?.where((element) => element.isYes == isYes)
            .first
        : null;
  }
}
