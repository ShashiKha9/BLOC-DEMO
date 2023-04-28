class GroupInviteContactDto {
  late String? id;
  late String firstName;
  late String lastName;
  late String phoneNumber;

  GroupInviteContactDto(
      {required this.firstName,
      this.id,
      required this.lastName,
      required this.phoneNumber});

  GroupInviteContactDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    phoneNumber = json['PhoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['PhoneNumber'] = phoneNumber;
    return data;
  }
}
