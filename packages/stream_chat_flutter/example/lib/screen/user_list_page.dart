import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamUserListController].
  late final userListController = StreamUserListController(
      client: StreamChatCore.of(context).client, filter: null);

  @override
  void initState() {
    userListController.doInitialLoad();
    super.initState();
  }

  @override
  void dispose() {
    userListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Select User"),
        ),
        body: PagedValueListenableBuilder<int, User>(
          valueListenable: userListController,
          builder: (context, value, child) {
            return value.when(
              (users, nextPageKey, error) => LazyLoadScrollView(
                onEndOfPage: () async {
                  if (nextPageKey != null) {
                    userListController.loadMore(nextPageKey);
                  }
                },
                child: ListView.builder(
                  /// We're using the users length when there are no more
                  /// pages to load and there are no errors with pagination.
                  /// In case we need to show a loading indicator or and error
                  /// tile we're increasing the count by 1.
                  itemCount: (nextPageKey != null || error != null)
                      ? users.length + 1
                      : users.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == users.length) {
                      if (error != null) {
                        return TextButton(
                          onPressed: () {
                            userListController.retry();
                          },
                          child: Text(error.message),
                        );
                      }
                      return const CircularProgressIndicator();
                    }

                    final _item = users[index];
                    return ListTile(
                      title: Text(_item.name),
                    );
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
      );
}
