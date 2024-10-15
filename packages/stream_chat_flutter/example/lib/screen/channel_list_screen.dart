import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_example/utils/translucent_scafold.dart';
import 'package:stream_chat_flutter_example/widgets/channel_item_widget.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamChannelListController].
  late final channelListController = StreamChannelListController(
    client: StreamChatCore.of(context).client,
    filter: Filter.and([
      Filter.equal('type', 'messaging'),
      Filter.in_(
        'members',
        [
          StreamChatCore.of(context).currentUser!.id,
        ],
      ),
    ]),
  );
  final _channelTextController = TextEditingController();

  @override
  void initState() {
    channelListController.doInitialLoad();
    super.initState();
  }

  @override
  void dispose() {
    channelListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TranslucentScaffold(
        body: SafeArea(
          child: Column(
            children: [
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
                  const Text("Your chats",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  thickness: 0.05,
                ),
              ),
              Expanded(
                child: PagedValueListenableBuilder<int, Channel>(
                  valueListenable: channelListController,
                  builder: (context, value, child) {
                    return value.when(
                      (channels, nextPageKey, error) => LazyLoadScrollView(
                        onEndOfPage: () async {
                          if (nextPageKey != null) {
                            channelListController.loadMore(nextPageKey);
                          }
                        },
                        child: ListView.separated(
                          /// We're using the channels length when there are no more
                          /// pages to load and there are no errors with pagination.
                          /// In case we need to show a loading indicator or and error
                          /// tile we're increasing the count by 1.
                          separatorBuilder: (context, index) => const Divider(
                            thickness: 0.1,
                          ),
                          itemCount: (nextPageKey != null || error != null)
                              ? channels.length + 1
                              : channels.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == channels.length) {
                              if (error != null) {
                                return TextButton(
                                  onPressed: () {
                                    channelListController.retry();
                                  },
                                  child: Text(error.message),
                                );
                              }
                              return const CircularProgressIndicator();
                            }

                            final item = channels[index];
                            final otherUser = item.state?.members
                                .firstWhere((element) =>
                                    element.userId !=
                                    StreamChatCore.of(context).currentUser?.id)
                                .user;

                            return ChannelItemWidget(
                                item: item, otherUser: otherUser);
                          },
                        ),
                      ),
                      loading: () => const Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e) => Center(
                        child: Text(
                          'Oh no, something went wrong. '
                          'Please check your config. $e',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Expanded(
                    //   child: TextFormField(
                    //     controller: _channelTextController,
                    //     decoration: const InputDecoration(
                    //         hintText: "Enter other user id"),
                    //   ),
                    // ),
                    ElevatedButton(
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           const GalleryPickerScreen(),
                          //     ));

                          return;

                          if (_channelTextController.text.isNotEmpty) {
                            StreamChatCore.of(context)
                                .client
                                .createChannel("messaging", channelData: {
                              "members": [
                                _channelTextController.text,
                                StreamChatCore.of(context).currentUser!.id
                              ]
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please enter other user id to create the channel")));
                          }
                        },
                        child: const Text("File picker")),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      );
}
