import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';

class GroupIncidentTypeModel {
  late String? id;
  late String name;
  late String description;
  late String groupId;
  late String? iconData;

  GroupIncidentTypeModel(
      {this.id,
      required this.name,
      required this.description,
      required this.groupId,
      this.iconData});

  GroupIncidentTypeModel.fromDto(GroupIncidentTypeDto dto) {
    id = dto.id;
    name = dto.name;
    groupId = dto.groupId;
    description = dto.description;
    iconData = dto.iconData;
  }

  GroupIncidentTypeDto toDto() {
    return GroupIncidentTypeDto(
        id: id,
        name: name,
        groupId: groupId,
        description: description,
        iconData: iconData);
  }
}
