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
  String? messageSource;

  ChatMessageModel(this.author, this.dateCreated, this.messageBody,
      {this.username,
      this.isLink,
      this.linkUrl,
      this.isMedia,
      this.mediaUrl,
      this.isClosed,
      this.messageSource});
}