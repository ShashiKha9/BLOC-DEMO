class AddressServiceResult {
  final String name;
  final String id;

  AddressServiceResult(this.name, this.id);
}

class AddressServiceDetail {
  final String? street;
  final String? street2;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? county;

  AddressServiceDetail(this.street, this.street2, this.city, this.state, this.zipCode,
      this.county);
}
