class GroupIncidentTypeDto {
  late String? id;
  late String name;
  late String description;
  late String groupId;
  late String? iconData;

  GroupIncidentTypeDto(
      {this.id,
      required this.name,
      required this.description,
      required this.groupId,
      this.iconData});

  GroupIncidentTypeDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"]?.toString();
    name = json["Name"];
    groupId = json["GroupId"].toString();
    description = json["Description"];
    iconData = json["IconData"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Name"] = name;
    data["GroupId"] = groupId;
    data["Description"] = description;
    data["IconData"] = iconData;
    return data;
  }
}
