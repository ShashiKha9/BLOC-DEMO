class GroupIncidentHistoryDto {
  late String signalId;
  late String username;
  late String incidentType;
  String? incidentTypeId;
  late String iconData;
  DateTime? incidentDate;
  bool? closed;

  GroupIncidentHistoryDto(
      {required this.signalId,
      required this.username,
      required this.incidentType,
      this.incidentTypeId,
      this.incidentDate,
      this.closed,
      required this.iconData});

  GroupIncidentHistoryDto.fromJson(Map<String, dynamic> json) {
    signalId = json['SignalId'] ?? "";
    username = json['Username'] ?? "";
    incidentType = json['IncidentType'] ?? "";
    incidentTypeId = json['IncidentTypeId'];
    incidentDate = DateTime.parse(json['IncidentDate']);
    closed = json['Closed'] == "true" ? true : false;
    iconData = json['IconData'];
  }
}
