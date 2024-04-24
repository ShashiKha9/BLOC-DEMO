class PasswordResetTokenDto {
  late String id;
  late String token;

  PasswordResetTokenDto({required this.id,required this.token});

  PasswordResetTokenDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['token'] = token;
    return data;
  }
}
