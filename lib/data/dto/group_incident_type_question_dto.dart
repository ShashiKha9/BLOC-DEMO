class GroupIncidentTypeQuestionDto {
  late String? id;
  late String question;
  late String incidentTypeId;
  late String? incidentType;
  late bool? isYes;
  late String groupId;
  late String? parentQuestionId;
  late List<GroupIncidentTypeQuestionDto>? childQuestions;

  GroupIncidentTypeQuestionDto(
      {required this.question,
      required this.incidentTypeId,
      required this.groupId,
      this.id,
      this.incidentType,
      this.isYes,
      this.parentQuestionId,
      this.childQuestions});

  GroupIncidentTypeQuestionDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    question = json["Question"];
    groupId = json["GroupId"];
    incidentTypeId = json["IncidentTypeId"];
    incidentType =
        json["IncidentType"] != null ? json["IncidentType"]["Name"] : "";
    isYes = json["IsYes"];
    parentQuestionId = json["ParentQuestionId"];
    childQuestions = json["ChildQuestions"] != null
        ? (json["ChildQuestions"] as Iterable)
            .map((e) => GroupIncidentTypeQuestionDto.fromJson(e))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Question"] = question;
    data["IncidentTypeId"] = incidentTypeId;
    data["IsYes"] = isYes;
    data["ParentQuestionId"] = parentQuestionId;
    data["GroupId"] = groupId;
    return data;
  }
}
