import 'package:rescu_organization_portal/data/dto/group_incident_type_question_option_dto.dart';

class GroupIncidentTypeQuestionDto {
  late String? id;
  late String question;
  late String incidentTypeId;
  late String? incidentType;
  late QuestionType questionType;
  late String groupId;
  late String? rootQuestionId;
  late String? parentOptionId;
  late List<GroupIncidentTypeQuestionOptionDto>? options;

  GroupIncidentTypeQuestionDto(
      {required this.question,
      required this.incidentTypeId,
      required this.groupId,
      this.id,
      this.incidentType,
      required this.questionType,
      this.parentOptionId,
      this.options,
      this.rootQuestionId});

  GroupIncidentTypeQuestionDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    question = json["Question"];
    groupId = json["GroupId"];
    incidentTypeId = json["IncidentTypeId"];
    incidentType =
        json["IncidentType"] != null ? json["IncidentType"]["Name"] : "";
    if (json["Options"] != null) {
      options = [];
      json["Options"].forEach((v) {
        options!.add(GroupIncidentTypeQuestionOptionDto.fromJson(v));
      });
    }
    questionType = getQuestionType(json["QuestionType"]);
    rootQuestionId = json["RootQuestionId"];
    parentOptionId = json["ParentOptionId"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Question"] = question;
    data["IncidentTypeId"] = incidentTypeId;
    data["GroupId"] = groupId;
    data["Options"] = options?.map((v) => v.toJson()).toList();
    data["QuestionType"] = getQuestionTypeString();
    data["RootQuestionId"] = rootQuestionId;
    data["ParentOptionId"] = parentOptionId;
    return data;
  }

  static getQuestionTypeDisplay(QuestionType questionType) {
    switch (questionType) {
      case QuestionType.text:
        return "Text";
      case QuestionType.singlePickList:
        return "Single Picklist";
      case QuestionType.multiPickList:
        return "Multi Picklist";
    }
  }

  getQuestionTypeString() {
    switch (questionType) {
      case QuestionType.text:
        return "Text";
      case QuestionType.singlePickList:
        return "SinglePickList";
      case QuestionType.multiPickList:
        return "MultiPickList";
    }
  }

  static getQuestionType(String questionTypeString) {
    switch (questionTypeString) {
      case "Text":
        return QuestionType.text;
      case "SinglePickList":
        return QuestionType.singlePickList;
      case "MultiPickList":
        return QuestionType.multiPickList;
    }
  }
}

enum QuestionType { text, singlePickList, multiPickList }
