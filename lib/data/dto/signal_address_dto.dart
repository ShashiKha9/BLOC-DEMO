class SignalAddressDto {
  String? postalCode;
  String? address;
  String? address2;
  String? friendlyAddress;
  String? state;
  String? city;

  SignalAddressDto(
      {this.postalCode,
      this.address,
      this.address2,
      this.friendlyAddress,
      this.state,
      this.city});

  SignalAddressDto.fromJson(Map<String, dynamic> json) {
    postalCode = json['PostalCode'];
    address = json['Address1'];
    address2 = json['Address2'];
    friendlyAddress = json['AddressName'];
    state = json['State'];
    city = json['City'];
  }
}
