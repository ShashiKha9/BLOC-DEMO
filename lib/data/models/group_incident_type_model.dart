import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';

class GroupIncidentTypeModel {
  late String? id;
  late String name;
  late String description;
  late String groupId;
  late bool specialDispatch;
  late String? iconData;
  late String? branchId;
  late List<String>? branches;
  late String color;

  GroupIncidentTypeModel(
      {this.id,
      required this.name,
      required this.description,
      required this.groupId,
      required this.specialDispatch,
      this.iconData,
      this.branchId,
      this.branches,
      required this.color});

  GroupIncidentTypeModel.fromDto(GroupIncidentTypeDto dto) {
    id = dto.id;
    name = dto.name;
    groupId = dto.groupId;
    specialDispatch = dto.specialDispatch;
    description = dto.description;
    iconData = dto.iconData;
    branchId = dto.branchId;
    color = dto.color;
  }

  GroupIncidentTypeDto toDto() {
    return GroupIncidentTypeDto(
        id: id,
        name: name,
        groupId: groupId,
        specialDispatch: specialDispatch,
        description: description,
        iconData: iconData,
        branches: branches,
        branchId: branchId,
        color: color);
  }
}
