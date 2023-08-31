import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/copy_branch_question_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';
import 'package:rescu_organization_portal/ui/widgets/spacer_size.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

class CopyBranchQuestionsModalState extends BaseModalRouteState {
  final String groupId;
  final String branchId;

  CopyBranchQuestionsModalState(this.groupId, this.branchId);

  final List<GroupBranchDto> _branches = [];
  final List<GroupIncidentTypeQuestionDto> _questions = [];
  final List<GroupIncidentTypeQuestionDto> _selectedQuestions = [];

  final List<GroupIncidentTypeDto> _incidentTypes = [];
  String? _selectedIncidentTypeId;

  final LoadingController _controller = LoadingController();
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    context.read<CopyBranchQuestionBloc>().add(GetBranches(groupId));
    context.read<CopyBranchQuestionBloc>().add(GetIncidentTypes(branchId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String getTitle() {
    return "Copy Branch Questions";
  }

  @override
  Widget content(BuildContext context) {
    return LoadingContainer(
        controller: _controller,
        child: BlocListener(
          bloc: context.read<CopyBranchQuestionBloc>(),
          listener: (ctx, state) {
            if (state is CopyBranchQuestionLoading) {
              _controller.show();
            } else {
              _controller.hide();

              if (state is CopyBranchQuestionBranchesLoaded) {
                _branches.clear();
                state.branches.removeWhere((element) => element.id == branchId);
                _branches.addAll(state.branches);
                if (_branches.isNotEmpty) {
                  _selectedBranchId = _branches.first.id!;
                  context
                      .read<CopyBranchQuestionBloc>()
                      .add(GetBranchQuestions(groupId, _branches.first.id!));
                } else {
                  ToastDialog.warning("No branches found");
                }
              }

              if (state is CopyBranchQuestionLoaded) {
                _questions.clear();
                _selectedQuestions.clear();
                _questions.addAll(state.questions);
                setState(() {});
              }

              if (state is IncidentTypeLoadedState) {
                _incidentTypes.clear();
                _incidentTypes.addAll(state.incidentTypes);
                if (_incidentTypes.isNotEmpty) {
                  _selectedIncidentTypeId = _incidentTypes.first.id;
                }
                setState(() {});
              }

              if (state is CopyBranchQuestionFailure) {
                ToastDialog.error(state.error);
              }

              if (state is CopyBranchQuestionSuccess) {
                ToastDialog.success("Questions copied successfully");
                Navigator.of(context).pop();
              }
            }
          },
          child: Form(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: TextInputDecoration(
                      labelText: "Copy To Incident Type",
                      hintText: "Select a incident type"),
                  value: _selectedIncidentTypeId,
                  onChanged: (value) {
                    _selectedIncidentTypeId = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a incident type to copy questions";
                    }
                    return null;
                  },
                  items: _incidentTypes
                      .map((e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(e.name),
                          ))
                      .toList(),
                ),
                SpacerSize.at(1.5),
                DropdownButtonFormField<String>(
                  decoration: TextInputDecoration(
                      labelText: "Branch", hintText: "Select a branch"),
                  value: _selectedBranchId,
                  onChanged: (value) {
                    _selectedBranchId = value;
                    context
                        .read<CopyBranchQuestionBloc>()
                        .add(GetBranchQuestions(groupId, value.toString()));
                  },
                  items: _branches
                      .map((e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(e.name),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (ctx, index) {
                      return AdaptiveListTile(
                          item: AdaptiveListItem(
                        "Question: ${_questions[index].question}",
                        "Incident Type: ${_questions[index].incidentType}",
                        _selectedQuestions.contains(_questions[index])
                            ? const Icon(Icons.check_box_rounded)
                            : const Icon(Icons.check_box_outline_blank),
                        [],
                        onPressed: () {
                          setState(() {
                            _selectedQuestions.contains(_questions[index])
                                ? _selectedQuestions.remove(_questions[index])
                                : _selectedQuestions.add(_questions[index]);
                          });
                        },
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [
      AdaptiveItemAction("SAVE", const Icon(Icons.save), () async {
        if (_selectedIncidentTypeId == null) {
          ToastDialog.error("Please select a incident type to copy questions");
          return;
        }

        if (_selectedQuestions.isEmpty) {
          ToastDialog.error("Please select at least one question to copy");
          return;
        }

        context.read<CopyBranchQuestionBloc>().add(CopyBranchQuestion(
            groupId, branchId, _selectedIncidentTypeId!, _selectedQuestions));
      }),
      AdaptiveItemAction("CANCEL", const Icon(Icons.cancel), () async {
        Navigator.of(context).pop();
      }),
    ];
  }
}
