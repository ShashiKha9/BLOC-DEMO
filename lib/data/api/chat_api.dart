import 'dart:convert';
import 'package:TEST/data/services/service_response.dart';
import 'package:dio/dio.dart';
import '../models/chat_model.dart';
import 'base_api.dart';

abstract class IChatAPI {
  Future<ServiceDataResponse<List<ChatMessageModel>>> getChatHistory(
      String channelID);

  Future<ApiDataResponse<String>> downloadMedia(String path);
}

class ChatApi extends BaseApi implements IChatAPI {
  ChatApi(Dio dio) : super(dio);

  @override
  Future<ServiceDataResponse<List<ChatMessageModel>>> getChatHistory(
      String channelID) async {
    try {
      var result = await dio.get("/signals/$channelID/chatHistory");
      var messages = <ChatMessageModel>[];
      var jsonMessages = jsonDecode(result.data);
      jsonMessages.forEach((message) {
        var chatModel = ChatMessageModel(
            message["Author"],
            DateTime.parse(message["Timestamp"] ?? DateTime.now()),
            message["Body"]);

        var properties = jsonDecode(message["Properties"]);
        if (properties["Username"] != null) {
          chatModel.username = properties["Username"];
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

        if (properties["MessageSource"] != null) {
          chatModel.messageSource = properties["MessageSource"];
        }

        messages.add(chatModel);
      });

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
