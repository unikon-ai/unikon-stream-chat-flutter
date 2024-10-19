import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:stream_chat_flutter_example/screen/channel_list_screen.dart';
import 'package:stream_chat_flutter_example/screen/user_list_page.dart';
import 'package:stream_chat_flutter_example/utils/stream_chat_utils.dart';

// Select user to whom you want to login
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter User name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Enter User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () async {
                  final PermissionState ps = await PhotoManager
                      .requestPermissionExtend(); // the method can use optional param `permission`.
                  if (ps.isAuth) {
                    // Granted
                    // You can to get assets here.
                    goToNextScreen(context);
                  } else if (ps.hasAccess) {
                    // Access will continue, but the amount visible depends on the user's selection.
                    goToNextScreen(context);
                  } else {
                    // Limited(iOS) or Rejected, use `==` for more precise judgements.
                    // You can call `PhotoManager.openSetting()` to open settings for further steps.
                    // show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please provide permission to access photos'),
                      ),
                    );
                  }
                },
                child: const Text("Login"))
          ],
        ),
      ),
    );
  }

  void goToNextScreen(BuildContext context) {
    try {
      // Connect user to StreamChatClient
      if (StreamChatUtils.getChatClient().state.currentUser == null) {
        StreamChatUtils.connectUser(
          User(
            id: _idController.text,
            name: _nameController.text,
            image: 'https://picsum.photos/200',
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    Future.delayed(const Duration(milliseconds: 100));

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChannelListScreen(),
        ));
  }
}
