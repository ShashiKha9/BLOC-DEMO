class GroupIncidentTypeDto {
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

  GroupIncidentTypeDto(
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

  GroupIncidentTypeDto.fromJson(Map<String, dynamic> json) {
    id = json["Id"]?.toString();
    name = json["Name"];
    groupId = json["GroupId"].toString();
    specialDispatch = json["SpecialDispatch"];
    description = json["Description"];
    iconData = json["IconData"];
    branchId = json["BranchId"];
    dispatchCode = json["DispatchCode"];
    color = json["Color"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["Id"] = id;
    data["Name"] = name;
    data["GroupId"] = groupId;
    data["SpecialDispatch"] = specialDispatch;
    data["Description"] = description;
    data["IconData"] = iconData;
    data["BranchIds"] = branches;
    data["BranchId"] = branchId;
    data["DispatchCode"] = dispatchCode;
    data["Color"] = color;
    data["AddAdmins"] = addAdmins ?? false;
    return data;
  }
}
