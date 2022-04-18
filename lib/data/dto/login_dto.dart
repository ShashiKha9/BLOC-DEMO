class LoginDto {
  late String accessToken;
  late String tokenType;
  late String expiresIn;
  late String customer;
  late String role;
  late String isFirstLogin;
  late String isOnlyPortalUser;
  late String issued;
  late String expires;
  late String emailAddress;
  late String provider;

  LoginDto(
      {required this.accessToken,
      required this.tokenType,
      required this.expiresIn,
      required this.customer,
      required this.role,
      required this.isFirstLogin,
      required this.isOnlyPortalUser,
      required this.issued,
      required this.expires,
      required this.emailAddress,
      required this.provider});

  LoginDto.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'] ?? "";
    tokenType = json['token_type'] ?? "";
    expiresIn = json['expires_in']?.toString() ?? "";
    customer = json['Customer'] ?? "";
    role = json['Role'] ?? "";
    isFirstLogin = json['IsFirstLogin'] ?? "";
    isOnlyPortalUser = json['IsOnlyPortalUser'] ?? "";
    issued = json['.issued'] ?? "";
    expires = json['.expires'] ?? "";
    emailAddress = json['emailAddress'] ?? "";
    provider = json['provider'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    data['expires_in'] = expiresIn;
    data['Customer'] = customer;
    data['Role'] = role;
    data['IsFirstLogin'] = isFirstLogin;
    data['IsOnlyPortalUser'] = isOnlyPortalUser;
    data['.issued'] = issued;
    data['.expires'] = expires;
    data['emailAddress'] = emailAddress;
    data['provider'] = provider;
    return data;
  }
}
