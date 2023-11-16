class GroupIncidentParticipantsDto {
  final String firstName;
  final String lastName;

  GroupIncidentParticipantsDto(
      {required this.firstName, required this.lastName});

  GroupIncidentParticipantsDto.fromJson(Map<String, dynamic> json)
      : firstName = json['FirstName'] ?? "",
        lastName = json['LastName'] ?? "";
}
