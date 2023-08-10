class GroupIncidentTypeDto {
  late String? id;
  late String name;
  late String description;
  late String groupId;
  late String? iconData;
  late String? branchId;
  late List<String>? branches;

  GroupIncidentTypeDto(
      {this.id,
      required this.name,
      required this.description,
      required this.groupId,
      this.iconData,
      this.branchId,
      this.branches});

  GroupIncidentTypeDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"]?.toString();
    name = json["Name"];
    groupId = json["GroupId"].toString();
    description = json["Description"];
    iconData = json["IconData"];
    branchId = json["BranchId"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Name"] = name;
    data["GroupId"] = groupId;
    data["Description"] = description;
    data["IconData"] = iconData;
    data["BranchIds"] = branches;
    return data;
  }
}
