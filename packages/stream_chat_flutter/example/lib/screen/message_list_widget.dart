import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_example/utils/custom_date_time.dart';

/// Contains list of messages
class MessageListWidget extends StatelessWidget {
  const MessageListWidget({super.key, required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        reverse: true,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msgByCurrentUser = messages[index].user?.id ==
              StreamChatCore.of(context).currentUser!.id;
          return Align(
            alignment:
                msgByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: msgByCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: msgByCurrentUser
                            ? Colors.teal
                            : const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        "${messages[index].text}",
                        style: const TextStyle(color: Colors.white),
                      )),
                  Align(
                    alignment: msgByCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      CustomDateTime.getFormattedTime(
                          messages[index].createdAt),
                      style: const TextStyle(color: Colors.black12),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
