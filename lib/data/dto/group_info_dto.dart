import 'group_type_dto.dart';

class GroupInfoDto {
  late String id;
  late String groupName;
  late GroupTypeDto groupType;

  GroupInfoDto(
      {required this.id, required this.groupName, required this.groupType});

  GroupInfoDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'].toString();
    groupName = json['Name'];
    groupType = GroupTypeDto.fromJson(json['GroupType']);
  }

  bool isFleetUser(){
    return groupType.normalisedName == "Fleet";
  }
}
