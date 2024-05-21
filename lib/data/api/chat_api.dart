import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/services/service_response.dart';
import '../../env.dart';
import '../models/chat_model.dart';
import 'base_api.dart';

abstract class IChatAPI {
  Future<ApiDataResponse<SocketChatHistoryResponse>> getChatHistory(
      String userToken, String channelID);

  Future<ServiceDataResponse<List<ChatMessageModel>>> parseChatMessages(
      String userToken, String channelID);
}

class ChatApi extends BaseApi implements IChatAPI {
  final ProjectConfiguration _env;
  late Dio _chatDio;

  ChatApi(Dio dio, this._env) : super(dio) {
    _chatDio = Dio(BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 300000,
        sendTimeout: 300000,
        baseUrl: _env.maukaUrl));
  }

  @override
  Future<ApiDataResponse<SocketChatHistoryResponse>> getChatHistory(
      String userToken, String channelID) async {
    return await wrapDataCall(() async {
      _chatDio.options.headers['Authorization'] = 'Bearer $userToken';
      var result = await _chatDio.get("/chat/" + channelID);
      return OkData(SocketChatHistoryResponse.fromJson(result.data));
    });
  }

  @override
  Future<ServiceDataResponse<List<ChatMessageModel>>> parseChatMessages(
      String userToken, String channelID) async {
    try {
      List<ChatMessageModel> chatMessagesModel = [];

      var messageHistory = await getChatHistory(userToken, channelID);
      if (messageHistory is OkData<SocketChatHistoryResponse>) {
        messageHistory.dto.data?.forEach((message) {
          var chatModel = ChatMessageModel(message.attributes?.author,
              DateTime.tryParse(message.createdAt ?? ""), message.message);

          var attributes = message.attributes;
          if (attributes != null) {
            chatModel.username = attributes.username;
            chatModel.isLink = attributes.isLink?.toLowerCase() == "true";
            chatModel.linkUrl = attributes.linkUrl;
            chatModel.isMedia = attributes.isMedia?.toLowerCase() == "true";
            chatModel.mediaUrl = attributes.mediaUrl;
          }

          chatMessagesModel.add(chatModel);
        });
      }
      return SuccessDataResponse(chatMessagesModel);
    } catch (e) {
      print(e);
      return FailureDataResponse("Error getting messages for chat");
    }
  }
}
