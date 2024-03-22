class GroupManageContactBranchDto {
  String? id;
  String? groupInfoId;
  String? name;
  String? phoneNumber;
  String? email;
  String? designation;
  String? loginWith;
  bool? canCloseChat;
  ContactBranch? contactBranch;

  GroupManageContactBranchDto(
      {this.id,
      this.groupInfoId,
      this.name,
      this.phoneNumber,
      this.email,
      this.designation,
      this.loginWith,
      this.canCloseChat,
      this.contactBranch});

  GroupManageContactBranchDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    groupInfoId = json['GroupInfoId'];
    name = json['Name'];
    phoneNumber = json['PhoneNumber'];
    email = json['Email'];
    designation = json['Designation'];
    loginWith = json['LoginWith'];
    canCloseChat = json['CanCloseChat'];
    contactBranch = json['ContactBranch'] != null
        ? ContactBranch.fromJson(json['ContactBranch'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['GroupInfoId'] = groupInfoId;
    data['Name'] = name;
    data['PhoneNumber'] = phoneNumber;
    data['Email'] = email;
    data['Designation'] = designation;
    data['LoginWith'] = loginWith;
    data['CanCloseChat'] = canCloseChat;
    if (contactBranch != null) {
      data['ContactBranch'] = contactBranch!.toJson();
    }
    return data;
  }
}

class ContactBranch {
  String? id;
  String? name;
  String? groupInfoId;
  bool? canAccess;
  List<ContactBrancheIncidents>? contactBrancheIncidents;

  ContactBranch(
      {this.id,
      this.name,
      this.groupInfoId,
      this.canAccess,
      this.contactBrancheIncidents});

  ContactBranch.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    groupInfoId = json['GroupInfoId'];
    canAccess = json['CanAccess'];
    if (json['ContactBrancheIncidents'] != null) {
      contactBrancheIncidents = <ContactBrancheIncidents>[];
      json['ContactBrancheIncidents'].forEach((v) {
        contactBrancheIncidents!.add(ContactBrancheIncidents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['GroupInfoId'] = groupInfoId;
    data['CanAccess'] = canAccess;
    if (contactBrancheIncidents != null) {
      data['ContactBrancheIncidents'] =
          contactBrancheIncidents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactBrancheIncidents {
  String? id;
  String? groupBranchId;
  String? name;
  String? description;
  bool? canAccess;

  ContactBrancheIncidents(
      {this.id,
      this.groupBranchId,
      this.name,
      this.description,
      this.canAccess});

  ContactBrancheIncidents.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    groupBranchId = json['GroupBranchId'];
    name = json['Name'];
    description = json['Description'];
    canAccess = json['CanAccess'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['GroupBranchId'] = groupBranchId;
    data['Name'] = name;
    data['Description'] = description;
    data['CanAccess'] = canAccess;
    return data;
  }
}
