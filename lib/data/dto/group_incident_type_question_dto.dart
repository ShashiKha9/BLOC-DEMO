class GroupIncidentTypeQuestionDto {
  late String? id;
  late String question;
  late String incidentTypeId;
  late String? incidentType;

  GroupIncidentTypeQuestionDto(
      {required this.question,
      required this.incidentTypeId,
      this.id,
      this.incidentType});

  GroupIncidentTypeQuestionDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    question = json["Question"];
    incidentTypeId = json["IncidentTypeId"];
    incidentType = json["GroupIncidentType"]["Name"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Question"] = question;
    data["IncidentTypeId"] = incidentTypeId;
    return data;
  }
}
