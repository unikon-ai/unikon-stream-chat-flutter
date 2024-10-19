import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A utility class to handle StreamChatClient
class StreamChatUtils {
  static StreamChatClient? _client;
  static const String _secretServerKey =
      "8zhqm8bquahp8zsrgwayv8y3833nzg6k8med5hgvx58jas8evjztyncpuqedf67w";

  /// initialize StreamChatClient
  static void init() {
    _client = getChatClient();
  }

  /// Get StreamChatClient instance, its a singleton instance
  static StreamChatClient getChatClient() {
    _client ??= StreamChatClient(
      "k7j58vzrpb5n",
      logLevel: Level.INFO,
    );
    return _client!;
  }

  /// connect user to StreamChatClient
  static Future<void> connectUser(User user) async {
    final client = getChatClient();

    await client.connectUser(
      user,
      _buildUserToken(user),
    );
  }

  static String _buildUserToken(User user) {
    // check for shard pref to find the token

    final jwt = JWT({
      'user_id': user.id,
    });
    final token = jwt.sign(SecretKey(_secretServerKey));

    return token;
  }
}
