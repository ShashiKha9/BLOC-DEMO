class AddressServiceResult {
  final String name;
  final String id;

  AddressServiceResult(this.name, this.id);
}

class AddressServiceDetail {
  final String? street;
  final String? street2;
  final String? city;
  final String? country;
  final String? state;
  final String? zipCode;
  final String? county;
  final double? latitude;
  final double? longitude;

  AddressServiceDetail(this.street, this.street2, this.city, this.country, this.state,
      this.zipCode, this.county,
      {this.latitude, this.longitude});
}
