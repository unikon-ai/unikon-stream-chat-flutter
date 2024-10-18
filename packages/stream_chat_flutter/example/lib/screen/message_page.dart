import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_example/utils/translucent_scafold.dart';
import 'package:stream_chat_flutter_example/widgets/message_input_widget.dart';

/// Displays the list of messages inside the channel
class MessagePage extends StatefulWidget {
  const MessagePage({
    super.key,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final StreamMessageInputController messageInputController =
      StreamMessageInputController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    final otherUser = channel.state?.members.firstWhere((element) =>
        element.userId != channel.state?.currentUserMember?.userId);

    final ValueNotifier<bool> isRecordingInProgress = ValueNotifier(false);

    return TranslucentScaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${otherUser?.user?.name}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white)),
                    const Text("3 Days left",
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFFCCCCCC))),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(
                thickness: 0.05,
              ),
            ),
            Expanded(
              child: StreamMessageListView(
                markReadWhenAtTheBottom: true,
                paginationLoadingIndicatorBuilder: (context) => const Center(
                  child: CupertinoActivityIndicator(),
                ),
                messageBuilder: (p0, details, p2, defaultMessageWidget) {
                  final userId = StreamChat.of(context).currentUser?.id;

                  return defaultMessageWidget.copyWith(
                      onReplyTap: reply,
                      showThreadReplyIndicator: false,
                      showReplyMessage: true,
                      showDeleteMessage: false,
                      showPinButton: false,
                      showThreadReplyMessage: true,
                      showReactions: false,
                      showReactionPicker: false,
                      showFlagButton: false,
                      showReactionBrowser: false,
                      showMarkUnreadMessage: false,
                      showUserAvatar: DisplayWidget.gone,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      attachmentShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      showUsername: false,
                      attachmentBuilders: [
                        // AudioAttachmentBuilder(
                        //   isMyMessage: details.isMyMessage,
                        // ),
                        ...StreamAttachmentWidgetBuilder.defaultBuilders(
                          userId: userId,
                          message: details.message,
                        ),
                      ]);
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isRecordingInProgress,
              builder: (BuildContext context, bool value, Widget? child) {
                return value
                    ? SizedBox()
                    // // ? VoiceRecordingWidget(
                    //     onRecordingSend: (recordedFilePath, fileWebFormData) {
                    //       final uri = Uri.parse(recordedFilePath);
                    //       File file = File(uri.path);
                    //       file.length().then(
                    //         (fileSize) {
                    //           StreamChannel.of(context).channel.sendMessage(
                    //                 Message(
                    //                   attachments: [
                    //                     Attachment(
                    //                       type: 'voicenote',
                    //                       file: AttachmentFile(
                    //                         size: fileSize,
                    //                         path: uri.path,
                    //                       ),
                    //                       extraData: {
                    //                         'waveForm': fileWebFormData,
                    //                       },
                    //                     )
                    //                   ],
                    //                 ),
                    //               );
                    //         },
                    //       );

                    //       // Recording is not in progress anymore
                    //       isRecordingInProgress.value = false;
                    //     },
                    //     onRecordingAborted: () {
                    //       // Recording is not in progress anymore
                    //       isRecordingInProgress.value = false;
                    //     },
                    //     onRecordingStarted: () {},
                    //   )

                    : StreamMessageInput(
                        messageInputController: messageInputController,
                        onQuotedMessageCleared:
                            messageInputController.clearQuotedMessage,
                        focusNode: focusNode,
                        enableActionAnimation: true,
                        actionsLocation: ActionsLocation.left,
                        actionsBuilder: (context, list) {
                          /// Remove gif button
                          return [
                            ...list,
                            IconButton(
                              icon: const Icon(Icons.mic),
                              onPressed: () {
                                isRecordingInProgress.value = true;
                              },
                            ),
                          ];
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  void reply(Message message) {
    messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }
}
