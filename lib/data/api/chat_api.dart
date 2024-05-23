import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/services/service_response.dart';
import '../models/chat_model.dart';
import 'base_api.dart';

abstract class IChatAPI {
  Future<ApiDataResponse<String>> getChatHistory(
      String userToken, String channelID);

  Future<ServiceDataResponse<List<ChatMessageModel>>> parseChatMessages(
      String userToken, String channelID);

  Future<ApiDataResponse<String>> downloadMedia(String path);
}

class ChatApi extends BaseApi implements IChatAPI {
  ChatApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<String>> getChatHistory(
      String userToken, String channelID) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/signals/$channelID/chatHistory");
      return OkData(result.data);
    });
  }

  @override
  Future<ServiceDataResponse<List<ChatMessageModel>>> parseChatMessages(
      String userToken, String channelID) async {
    try {
      var messages = <ChatMessageModel>[];

      var messageHistory = await getChatHistory(userToken, channelID);
      if (messageHistory is OkData<String>) {
        var jsonMessages = jsonDecode(messageHistory.dto);

        jsonMessages.forEach((message) {
          var chatModel = ChatMessageModel(
              message["Author"],
              DateTime.parse(message["Timestamp"] ?? DateTime.now()),
              message["Body"]);

          var properties = jsonDecode(message["Properties"]);
          if (properties["Username"] != null) {
            chatModel.username = properties["Username"];
          }

          if (properties["username"] != null) {
            chatModel.username = properties["username"];
          }

          if (properties["IsLink"] != null) {
            chatModel.isLink = properties["IsLink"];
          }

          if (properties["LinkUrl"] != null) {
            chatModel.linkUrl = properties["LinkUrl"];
          }

          if (properties["IsMedia"] != null) {
            chatModel.isMedia = properties["IsMedia"];
          }

          if (properties["MediaUrl"] != null) {
            chatModel.mediaUrl = properties["MediaUrl"];
          }

          if (properties["IsClosed"] != null) {
            chatModel.isClosed = properties["IsClosed"];
          }

          messages.add(chatModel);
        });
      }

      return SuccessDataResponse(messages);
    } catch (e) {
      return FailureDataResponse("Error parsing messages for chat");
    }
  }

  @override
  Future<ApiDataResponse<String>> downloadMedia(String path) async {
    return await wrapDataCall(() async {
      Response result =
          await dio.get("chat/media", queryParameters: {"mediaPath": path});
      return OkData(result.data);
    });
  }
}
