import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_example/screen/message_page.dart';

class ChannelItemWidget extends StatelessWidget {
  const ChannelItemWidget({super.key, required this.item, this.otherUser});

  final Channel item;
  final User? otherUser;

  @override
  Widget build(BuildContext context) => _buildChannelItem(
        context,
      );

  /// Builds the channel item
  Widget _buildChannelItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StreamChannel(
              channel: item,
              child: const MessagePage(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      otherUser?.image ?? '',
                    ),
                  ),
                )),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "${otherUser?.name}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<int?>(
                        stream: item.state!.unreadCountStream,
                        initialData: item.state!.unreadCount,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data! > 0
                                ? CircleAvatar(
                                    radius: 7,
                                    backgroundColor: Colors.teal,
                                    child: Text(
                                      snapshot.data! > 99
                                          ? "99+"
                                          : snapshot.data.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          }

                          return const SizedBox();
                        },
                      )
                    ],
                  ),
                  StreamBuilder<Message?>(
                    stream: item.state!.lastMessageStream,
                    initialData: item.state!.lastMessage,
                    builder: (context, snapshot) {
                      const style = TextStyle(
                        fontSize: 12,
                        color: Color(0xFF808080),
                        fontWeight: FontWeight.w400,
                      );
                      if (snapshot.hasData) {
                        return snapshot.data?.text == null ||
                                snapshot.data!.text!.isEmpty
                            ? Text(
                                snapshot.data!.type,
                                style: style,
                              )
                            : Text(
                                snapshot.data!.text!,
                                style: style,
                              );
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DateTime?>(
                  stream: item.state!.lastMessageStream
                      .map((event) => event?.createdAt),
                  initialData: item.state!.lastMessage?.updatedAt,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        "${snapshot.data!.toLocal().hour}:${snapshot.data!.toLocal().minute}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCCCCCC),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "3 Days left",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF808080),
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
