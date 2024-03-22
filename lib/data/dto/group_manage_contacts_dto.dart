class GroupManageContactBranchDto {
  String? inviteId;
  String? groupInfoId;
  String? name;
  String? phoneNumber;
  String? email;
  String? designation;
  String? loginWith;
  bool? canCloseChat;
  ContactBranch? contactBranch;

  GroupManageContactBranchDto(
      {this.inviteId,
      this.groupInfoId,
      this.name,
      this.phoneNumber,
      this.email,
      this.designation,
      this.loginWith,
      this.canCloseChat,
      this.contactBranch});

  GroupManageContactBranchDto.fromJson(Map<String, dynamic> json) {
    inviteId = json['InviteId'];
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
    data['InviteId'] = inviteId;
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
  String? branchId;
  String? name;
  String? groupInfoId;
  bool? canAccess;
  List<ContactBranchesIncidents>? contactBranchesIncidents;

  ContactBranch(
      {this.branchId,
      this.name,
      this.groupInfoId,
      this.canAccess,
      this.contactBranchesIncidents});

  ContactBranch.fromJson(Map<String, dynamic> json) {
    branchId = json['BranchId'];
    name = json['Name'];
    groupInfoId = json['GroupInfoId'];
    canAccess = json['CanAccess'];
    if (json['ContactBranchesIncidents'] != null) {
      contactBranchesIncidents = <ContactBranchesIncidents>[];
      json['ContactBranchesIncidents'].forEach((v) {
        contactBranchesIncidents!.add(ContactBranchesIncidents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BranchId'] = branchId;
    data['Name'] = name;
    data['GroupInfoId'] = groupInfoId;
    data['CanAccess'] = canAccess;
    if (contactBranchesIncidents != null) {
      data['ContactBranchesIncidents'] =
          contactBranchesIncidents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactBranchesIncidents {
  String? incidentId;
  String? groupBranchId;
  String? name;
  String? description;
  bool? canAccess;

  ContactBranchesIncidents(
      {this.incidentId,
      this.groupBranchId,
      this.name,
      this.description,
      this.canAccess});

  ContactBranchesIncidents.fromJson(Map<String, dynamic> json) {
    incidentId = json['IncidentId'];
    groupBranchId = json['GroupBranchId'];
    name = json['Name'];
    description = json['Description'];
    canAccess = json['CanAccess'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IncidentId'] = incidentId;
    data['GroupBranchId'] = groupBranchId;
    data['Name'] = name;
    data['Description'] = description;
    data['CanAccess'] = canAccess;
    return data;
  }
}
