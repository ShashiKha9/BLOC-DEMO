class GroupInviteContactDto {
  late String? id;
  late String firstName;
  late String lastName;
  late String phoneNumber;
  late bool isActive;
  late String? email;
  late String? designation;
  late String role;
  late String? loginWith;
  late List<String>? incidentTypeList;
  GroupInviteContactDto(
      {required this.firstName,
      this.id,
      required this.lastName,
      required this.phoneNumber,
      required this.isActive,
      required this.role,
      this.email,
      this.designation,
      this.incidentTypeList,
      this.loginWith});

  GroupInviteContactDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    phoneNumber = json['PhoneNumber'];
    isActive = json['IsActive'];
    email = json['Email'];
    designation = json['Designation'];
    role = json['Role'] ?? "";
    loginWith = json["LoginWith"] ?? "";
    incidentTypeList = List<String>.from(json["IncidentTypeList"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['PhoneNumber'] = phoneNumber;
    data['IsActive'] = isActive;
    data['Email'] = email;
    data['Designation'] = designation;
    data['Role'] = role;
    data["IncidentTypeList"] = incidentTypeList ?? [];
    data["LoginWith"] = loginWith;
    return data;
  }
}
