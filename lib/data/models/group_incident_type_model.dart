
import 'package:TEST/data/dto/group_incident_type_dto.dart';

class GroupIncidentTypeModel {
  late String? id;
  late String name;
  late String description;
  late String groupId;
  late bool specialDispatch;
  late String? iconData;
  late String? branchId;
  late String? dispatchCode;
  late List<String>? branches;
  late String color;
  bool? addAdmins;

  GroupIncidentTypeModel(
      {this.id,
      required this.name,
      required this.description,
      required this.groupId,
      required this.specialDispatch,
      this.iconData,
      this.branchId,
      this.dispatchCode,
      this.branches,
      required this.color,
      this.addAdmins});

  GroupIncidentTypeModel.fromDto(GroupIncidentTypeDto dto) {
    id = dto.id;
    name = dto.name;
    groupId = dto.groupId;
    specialDispatch = dto.specialDispatch;
    description = dto.description;
    iconData = dto.iconData;
    branchId = dto.branchId;
    dispatchCode = dto.dispatchCode;
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
        dispatchCode: dispatchCode,
        color: color,
        addAdmins: addAdmins);
  }
}
