import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';

class GroupIncidentTypeQuestionOptionDto {
  late String? id;
  late String optionText;
  late String? questionId;
  late List<GroupIncidentTypeQuestionDto>? childQuestions;

  GroupIncidentTypeQuestionOptionDto(
      {this.id,
      required this.optionText,
      this.questionId,
      this.childQuestions});

  GroupIncidentTypeQuestionOptionDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    optionText = json["OptionText"];
    questionId = json["QuestionId"];
    if (json["ChildQuestions"] != null) {
      childQuestions = [];
      json["ChildQuestions"].forEach((v) {
        childQuestions!.add(GroupIncidentTypeQuestionDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["OptionText"] = optionText;
    data["QuestionId"] = questionId;
    return data;
  }
}
