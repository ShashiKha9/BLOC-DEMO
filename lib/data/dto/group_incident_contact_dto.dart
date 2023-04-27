class GroupIncidentContactDto {
  late String? id;
  late String firstName;
  late String lastName;
  late String phoneNumber;
  late String? email;
  late String? designation;

  GroupIncidentContactDto(
      {this.designation,
      this.email,
      required this.firstName,
      this.id,
      required this.lastName,
      required this.phoneNumber});

  GroupIncidentContactDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    phoneNumber = json['PhoneNumber'];
    email = json['Email'];
    designation = json['Designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['PhoneNumber'] = phoneNumber;
    data['Email'] = email;
    data['Designation'] = designation;
    return data;
  }
}
