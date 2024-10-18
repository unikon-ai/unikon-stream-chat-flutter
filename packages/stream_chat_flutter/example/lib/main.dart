import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_example/screen/login_screen.dart';
import 'package:stream_chat_flutter_example/utils/shared_pref_utils.dart';
import 'package:stream_chat_flutter_example/utils/stream_chat_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefUtils.init();
  StreamChatUtils.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        builder: (context, child) => StreamChat(
              client: StreamChatUtils.getChatClient(),
              streamChatThemeData: buildStreamChatThemeData(),
              child: child,
            ),
        home: LoginScreen());
  }

  /// Builds the [StreamChatThemeData] for the app
  StreamChatThemeData buildStreamChatThemeData() {
    return StreamChatThemeData(
      colorTheme: StreamColorTheme.dark(
        accentPrimary: Colors.teal,
      ),
      voiceRecordingTheme: StreamVoiceRecordingThemeData(
          loadingTheme: StreamVoiceRecordingLoadingThemeData(),
          sliderTheme: StreamVoiceRecordingSliderTheme(),
          listPlayerTheme: StreamVoiceRecordingListPlayerThemeData(),
          playerTheme: StreamVoiceRecordingPlayerThemeData()),
      otherMessageTheme: const StreamMessageThemeData(
        messageTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      ownMessageTheme: const StreamMessageThemeData(
          messageTextStyle: TextStyle(
            color: Colors.white,
          ),
          messageBackgroundColor: Colors.teal),
      channelHeaderTheme: const StreamChannelHeaderThemeData(
        color: Colors.white,
        titleStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      messageListViewTheme: const StreamMessageListViewThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
