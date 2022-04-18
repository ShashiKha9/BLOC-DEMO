class GroupDomainDto {
  late String id;
  late String domain;
  late String groupId;

  GroupDomainDto(
      {required this.id, required this.domain, required this.groupId});

  GroupDomainDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'].toString();
    domain = json['Domain'];
    groupId = json['GroupId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Domain'] = domain;
    data['GroupId'] = groupId;
    return data;
  }
}
