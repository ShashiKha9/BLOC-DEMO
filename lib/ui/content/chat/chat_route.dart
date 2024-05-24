import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/blocs/chat_bloc.dart';
import '../../../data/models/chat_model.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/loading_container.dart';

const List<String> _imgFileExtentions = [
  "jpg",
  "jpeg",
  "jpe",
  "jif",
  "jfif",
  "jfi",
  "png",
  "gif",
  "webp",
  "tiff",
  "tif",
  "psd",
  "raw",
  "arw",
  "cr2",
  "nrw",
  "k25",
  "bmp",
  "dib",
  "heif",
  "heic",
  "ind",
  "indd",
  "indt",
  "jp2",
  "j2k",
  "jpf",
  "jpx",
  "jpm",
  "mj2",
  "svg",
  "svgz",
  "ai",
  "eps"
];

const List<String> _videoFileExtentions = [
  "WEBM",
  "MPG",
  "MP2",
  "MPEG",
  "MPE",
  "MPV",
  "OGG",
  "MP4",
  "M4P",
  "M4V",
  "AVI",
  "WMV",
  "MOV",
  "QT",
  "FLV",
  "SWF",
  "AVCHD"
];

const List<String> _pdfFileExtentions = ["pdf"];

class ChatRoute extends BaseModalRouteState {
  final String incidentId;
  ChatRoute(this.incidentId);

  List<ChatMessageModel> _messages = [];
  final String? _identity = "";
  final LoadingController _loadingController = LoadingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(GetChatHistory(incidentId));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollToBottom() {
    //Added Future.delayed to scroll to bottom if new messages are added to the chat or else it doesn't work.
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          if (_scrollController.offset <
              _scrollController.position.maxScrollExtent) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        }
      }
    });
  }

  @override
  Widget content(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: _loadingController,
      child: BlocListener(
        bloc: context.read<ChatBloc>(),
        listener: (listenerBuildContext, ChatStates state) async {
          if (state is ChatLoadingState) {
            _loadingController.show();
          } else {
            _loadingController.hide();

            if (state is ChatLoadMessagesState) {
              if (state.messages.isEmpty) {
                ToastDialog.error("No Messages Found");
                return;
              } else {
                setState(() {
                  _messages = state.messages;
                  _scrollToBottom();
                });
              }
            }
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.transparent,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessageModel message, int index) {
    return ((message.author ?? "") == "system" ||
            (message.username ?? "") == "system")
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    message.messageBody ?? "",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
            ],
          )
        : index != 0
            ? _buildMessageBody(message)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        _getChatHeaderText(message.dateCreated!),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _buildMessageBody(message),
                ],
              );
  }

  Widget _buildMessageBody(ChatMessageModel message) {
    var currentUserIsAuthor = message.author == _identity;
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: currentUserIsAuthor ? 60 : 8,
        right: currentUserIsAuthor ? 8 : 60,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: !currentUserIsAuthor
              ? const Color(0xffedf0f0)
              : const Color(0xffe9faed),
          border: const Border(),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: (message.isMedia ?? false)
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentUserIsAuthor
                    ? "You"
                    : (message.author ?? message.username ?? "Rescu"),
                style: const TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            message.isLink ?? false
                ? InkWell(
                    onTap: () async {
                      if (message.linkUrl != null &&
                          await canLaunchUrl(
                              Uri.parse(message.linkUrl ?? ""))) {
                        await launchUrl(Uri.parse(message.linkUrl ?? ""),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      message.messageBody ?? "",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 6, 115, 211),
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.start,
                    ),
                  )
                : message.isMedia ?? false
                    ? InkWell(
                        onTap: () {
                          context
                              .read<ChatBloc>()
                              .add(DownloadMedia(message.mediaUrl ?? ""));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildThumbnail(message.mediaUrl ?? ""),
                            Text(
                              _getMediaBodyText(
                                  message.mediaUrl ?? "", context),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 6, 115, 211),
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ))
                    : Text(
                        message.messageBody ?? '',
                        style: const TextStyle(
                            color: Color(0xff192e40),
                            fontWeight: FontWeight.w900),
                        textAlign: TextAlign.start,
                      ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat.jm().format(message.dateCreated!.toLocal()),
                style: const TextStyle(
                    color: Color(0xff192e40), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  List<AdaptiveItemAction> getActions() {
    return [];
  }

  @override
  String getTitle() {
    return "Chat History";
  }
}

Widget _buildThumbnail(String mediaUrl) {
  IconData icon = Icons.file_download;
  String fileExtention = "";
  try {
    fileExtention = mediaUrl.split(".").last.toLowerCase();
  } catch (_) {}
  if (_imgFileExtentions.any((x) => x.toLowerCase() == fileExtention)) {
    icon = Icons.image;
  } else if (_videoFileExtentions
      .any((x) => x.toLowerCase() == fileExtention)) {
    icon = Icons.video_file;
  } else if (_pdfFileExtentions.any((x) => x.toLowerCase() == fileExtention)) {
    icon = Icons.picture_as_pdf;
  }
  return Icon(
    icon,
    color: const Color.fromARGB(255, 6, 115, 211),
    size: 80,
  );
}

String _getMediaBodyText(String mediaUrl, BuildContext context) {
  String bodyTxt = "Download File";
  String fileExtention = "";
  try {
    fileExtention = mediaUrl.split(".").last.toLowerCase();
  } catch (_) {}
  if (_imgFileExtentions.any((x) => x.toLowerCase() == fileExtention)) {
    bodyTxt = "Download Image";
  } else if (_videoFileExtentions
      .any((x) => x.toLowerCase() == fileExtention)) {
    bodyTxt = "Download Video";
  } else if (_pdfFileExtentions.any((x) => x.toLowerCase() == fileExtention)) {
    bodyTxt = "Download Pdf";
  }
  return bodyTxt;
}

String _getChatHeaderText(DateTime dateToCompare) {
  final now = DateTime.now();
  //Condition for today
  if (now.toLocal().day == dateToCompare.toLocal().day &&
      now.toLocal().month == dateToCompare.toLocal().month &&
      now.toLocal().year == dateToCompare.toLocal().year) {
    return "Today at ${DateFormat.jm().format(dateToCompare.toLocal())}";
  }
  //Condition for yesterday
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  if (yesterday.toLocal().day == dateToCompare.toLocal().day &&
      yesterday.toLocal().month == dateToCompare.toLocal().month &&
      yesterday.toLocal().year == dateToCompare.toLocal().year) {
    return "Yesterday at ${DateFormat.jm().format(dateToCompare.toLocal())}";
  }
  return DateFormat.MMMEd().format(dateToCompare.toLocal());
}
