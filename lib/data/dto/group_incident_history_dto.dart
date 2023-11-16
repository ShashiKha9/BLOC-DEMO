import 'package:rescu_organization_portal/data/dto/group_incident_participants_dto.dart';
import 'package:rescu_organization_portal/data/dto/signal_address_dto.dart';

enum SignalType { test, police, medical, fire, cancel, unknown, incident }

class GroupIncidentHistoryDto {
  late String signalId;
  late SignalType signalType;
  late String username;
  late String incidentType;
  String? incidentTypeId;
  late String iconData;
  DateTime? incidentDate;
  bool? closed;
  late List<GroupIncidentParticipantsDto> participants;
  SignalAddressDto? address;

  GroupIncidentHistoryDto(
      {required this.signalId,
      required this.username,
      required this.incidentType,
      this.incidentTypeId,
      this.incidentDate,
      this.closed,
      required this.iconData,
      required this.signalType,
      required this.participants});

  GroupIncidentHistoryDto.fromJson(Map<String, dynamic> json) {
    signalId = json['IncidentId'].toString();
    username = json['Username'] ?? "";
    incidentType = json['IncidentType'] ?? "";
    incidentTypeId = json['IncidentTypeId'];
    incidentDate = DateTime.parse(json['IncidentDate']);
    closed = json['Closed'];
    iconData = json['IconData'];
    signalType = from(json['SignalType']);
    participants = json['Participants'] == null
        ? []
        : (json['Participants'] as Iterable)
            .map((e) => GroupIncidentParticipantsDto.fromJson(e))
            .toList();
    address = json['Address'] == null
        ? null
        : SignalAddressDto.fromJson(json['Address']);
  }

  SignalType from(String? code) {
    switch (code) {
      case "E":
        return SignalType.test;
      case "PD":
        return SignalType.police;
      case "MD":
        return SignalType.medical;
      case "FD":
        return SignalType.fire;
      case "CAN":
        return SignalType.cancel;
      case "INC":
        return SignalType.incident;
      default:
        return SignalType.unknown;
    }
  }
}
