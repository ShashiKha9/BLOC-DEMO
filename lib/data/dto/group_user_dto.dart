class GroupUserDto {
  late String id;
  late String email;
  late String groupId;
  late bool isExcluded;

  GroupUserDto(
      {required this.id,
      required this.email,
      required this.groupId,
      required this.isExcluded});

  GroupUserDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'].toString();
    email = json['Email'];
    groupId = json['GroupId'].toString();
    isExcluded = json['IsExcluded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Email'] = email;
    data['GroupId'] = groupId;
    data['IsExcluded'] = isExcluded;
    return data;
  }
}
