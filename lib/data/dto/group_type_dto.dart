class GroupTypeDto {
  late String id;
  late String name;
  late String normalisedName;

  GroupTypeDto(
      {required this.id, required this.name, required this.normalisedName});

  GroupTypeDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    normalisedName = json['NormalisedName'];
  }
}
