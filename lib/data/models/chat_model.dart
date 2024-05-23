class ChatMessageModel {
  final String? author;
  final DateTime? dateCreated;
  final String? messageBody;
  String? username;
  bool? isMedia;
  String? mediaUrl;
  bool? isLink;
  String? linkUrl;
  bool? isClosed;

  ChatMessageModel(this.author, this.dateCreated, this.messageBody,
      {this.username,
      this.isLink,
      this.linkUrl,
      this.isMedia,
      this.mediaUrl,
      this.isClosed});
}

class LastChatMessageItemModel {
  DateTime dateCreated;
  String channelID;

  LastChatMessageItemModel(
      {required this.dateCreated, required this.channelID});

  factory LastChatMessageItemModel.fromJson(Map<String, dynamic> json) {
    return LastChatMessageItemModel(
        dateCreated: DateTime.parse(json["date"]),
        channelID: json["channel_friendly_name"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': dateCreated.toIso8601String(),
      'channel_friendly_name': channelID,
    };
  }
}

class ChatTokenDto {
  String accessToken;
  String accessTokenAPN;

  ChatTokenDto({required this.accessToken, required this.accessTokenAPN});

  ChatTokenDto.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        accessTokenAPN = json['accessTokenAPN'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['accessTokenAPN'] = accessTokenAPN;
    return data;
  }
}

class ChatTokenModel {
  String accessToken;
  String accessTokenAPN;

  ChatTokenModel({required this.accessToken, required this.accessTokenAPN});

  ChatTokenModel.fromDto(ChatTokenDto dto)
      : accessToken = dto.accessToken,
        accessTokenAPN = dto.accessTokenAPN;

  ChatTokenDto toDto() {
    return ChatTokenDto(
        accessToken: accessToken, accessTokenAPN: accessTokenAPN);
  }
}
