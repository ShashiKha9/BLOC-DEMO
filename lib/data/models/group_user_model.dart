import 'package:TEST/data/dto/group_user_dto.dart';

class GroupUserModel {
  late String id;
  late String email;
  late String groupId;
  late bool isExcluded;

  GroupUserModel(
      {required this.id,
      required this.email,
      required this.groupId,
      required this.isExcluded});

  GroupUserModel.fromDto(GroupUserDto dto) {
    id = dto.id;
    email = dto.email;
    groupId = dto.groupId;
    isExcluded = dto.isExcluded;
  }

  GroupUserDto toDto() {
    return GroupUserDto(
        id: id, email: email, groupId: groupId, isExcluded: isExcluded);
  }
}
