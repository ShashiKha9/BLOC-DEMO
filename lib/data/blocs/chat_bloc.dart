import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rescu_organization_portal/data/api/chat_api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/base_api.dart';
import '../models/chat_model.dart';
import '../services/service_response.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetChatHistory extends ChatEvent {
  final String incidentID;

  GetChatHistory(this.incidentID);

  @override
  List<Object?> get props => [incidentID];
}

class OpenAttachmentDialog extends ChatEvent {}

class DownloadMedia extends ChatEvent {
  final String mediaPath;

  DownloadMedia(this.mediaPath);

  @override
  List<Object> get props => [mediaPath];
}

abstract class ChatStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatStates {}

class ChatLoadingState extends ChatStates {}

class ChatNotConnectedState extends ChatStates {}

class ChatErrorState extends ChatStates {
  final String errorMessage;

  ChatErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ChatLoadMessagesState extends ChatStates {
  final List<ChatMessageModel> messages;

  ChatLoadMessagesState(this.messages);

  @override
  List<Object> get props => [messages];
}

class DownloadMediaState extends ChatStates {}

class ChatBloc extends Bloc<ChatEvent, ChatStates> {
  final IChatAPI _chatAPI;
  ChatBloc(this._chatAPI) : super(ChatInitialState());

  @override
  Stream<ChatStates> mapEventToState(ChatEvent event) async* {
    if (event is GetChatHistory) {
      yield ChatLoadingState();

      var chatMessagesModelList = await _chatAPI.parseChatMessages(event.incidentID);
      if (chatMessagesModelList
          is SuccessDataResponse<List<ChatMessageModel>>) {
        yield ChatLoadMessagesState(chatMessagesModelList.result);
        return;
      }
    }

    if (event is DownloadMedia) {
      yield ChatLoadingState();
      var mediaRes = await _chatAPI.downloadMedia(event.mediaPath);
      if (mediaRes is BadData<String>) {
        return;
      } else {
        if (mediaRes is OkData<String>) {
          if (await canLaunchUrl(Uri.parse(mediaRes.dto))) {
            await launchUrl(Uri.parse(mediaRes.dto),
                mode: LaunchMode.externalApplication);
                yield DownloadMediaState();
          }
          return;
        }
      }
    }
  }
}
