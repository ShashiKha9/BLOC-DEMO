class GroupAddressDto {
  late String? id;
  late String name;
  late String address1;
  late String? address2;
  late String state;
  late String city;
  late String zipCode;
  late String? county;
  late String? crossStreet;
  late bool isDefault;
  late double? lat;
  late double? long;
  late List<String>? branchIds;

  GroupAddressDto(
      {required this.address1,
      this.address2,
      required this.city,
      this.county,
      this.crossStreet,
      this.id,
      required this.isDefault,
      required this.name,
      required this.state,
      required this.zipCode,
      this.lat,
      this.long,
      this.branchIds});

  GroupAddressDto.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['AddressName'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    state = json['State'];
    city = json['City'];
    zipCode = json['ZipCode'];
    county = json['County'];
    crossStreet = json['CrossStreet'];
    isDefault = json['Default'];
    lat = json['Latitude'];
    long = json['Longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['AddressName'] = name;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['State'] = state;
    data['City'] = city;
    data['ZipCode'] = zipCode;
    data['County'] = county;
    data['CrossStreet'] = crossStreet;
    data['Default'] = isDefault;
    data['Latitude'] = lat;
    data['Longitude'] = long;
    data['BranchIds'] = branchIds;
    return data;
  }
}
