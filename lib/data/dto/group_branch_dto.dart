class GroupBranchDto {
  late String? id;
  late String groupId;
  late String name;
  late bool active;

  GroupBranchDto(
      {this.id,
      required this.groupId,
      required this.name,
      required this.active});

  GroupBranchDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    groupId = json['GroupInfoId'];
    name = json['Name'];
    active = json['Active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['groupInfoId'] = groupId;
    data['name'] = name;
    data['active'] = active;

    return data;
  }
}
