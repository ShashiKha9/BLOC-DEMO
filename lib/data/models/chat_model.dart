class SocketChatHistoryResponse {
  String? message;
  List<ChatHistoryData>? data;

  SocketChatHistoryResponse({this.message, this.data});

  SocketChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <ChatHistoryData>[];
      json['data'].forEach((v) {
        data!.add(ChatHistoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatHistoryData {
  String? sId;
  String? channelId;
  String? senderId;
  String? name;
  String? messageType;
  String? message;
  Attributes? attributes;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? isSystemMessage;

  ChatHistoryData(
      {this.sId,
      this.channelId,
      this.senderId,
      this.name,
      this.messageType,
      this.message,
      this.attributes,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  ChatHistoryData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    channelId = json['channel_id'];
    senderId = json['sender_id'];
    name = json['name'];
    messageType = json['message_type'];
    message = json['message'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isSystemMessage = json['is_system_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['channel_id'] = channelId;
    data['sender_id'] = senderId;
    data['name'] = name;
    data['message_type'] = messageType;
    data['message'] = message;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['is_system_message'] = isSystemMessage;
    return data;
  }
}

class Attributes {
  String? author;
  String? dateCreated;
  String? isClosed;
  String? isMedia;
  String? mediaUrl;
  String? username;
  String? fileName;
  String? mediaContent;
  String? mediaType;
  String? messageType;
  String? isLink;
  String? linkUrl;

  Attributes(
      {author,
      dateCreated,
      isClosed,
      isMedia,
      mediaUrl,
      username,
      fileName,
      mediaContent,
      mediaType,
      messageType,
      isLink,
      linkUrl});

  Attributes.fromJson(Map<String, dynamic> json) {
    author = json['author'];
    dateCreated = json['dateCreated'];
    isClosed = json['isClosed'];
    isMedia = json['isMedia'];
    mediaUrl = json['mediaUrl'];
    username = json['username'];
    fileName = json['file_name'];
    mediaContent = json['media_content'];
    mediaType = json['media_type'];
    messageType = json['message_type'];
    isLink = json['isLink'];
    linkUrl = json['linkUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['dateCreated'] = dateCreated;
    data['isClosed'] = isClosed;
    data['isMedia'] = isMedia;
    data['mediaUrl'] = mediaUrl;
    data['username'] = username;
    data['file_name'] = fileName;
    data['media_content'] = mediaContent;
    data['media_type'] = mediaType;
    data['message_type'] = messageType;
    data['isLink'] = isLink;
    data['linkUrl'] = linkUrl;
    return data;
  }
}

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
