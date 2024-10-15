import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefKeys {
  static const String userIdKey = "userIdKey";
  static const String authTokenKey = "authTokenKey";
  static const String nameKey = "nameKey";
  SharedPrefKeys._();
}

class SharedPrefUtils {
  static SharedPreferences? _instance;

  static Future<void> init() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  static Future<void> setAuthToken(String authToken) async {
    await _instance?.setString(SharedPrefKeys.authTokenKey, authToken);
  }

  static String? getAuthToken() =>
      _instance?.getString(SharedPrefKeys.authTokenKey);

  static Future<void> setUserId(String userId) async {
    await _instance?.setString(SharedPrefKeys.userIdKey, userId);
  }

  static Future<void> setUserName(String name) async {
    await _instance?.setString(SharedPrefKeys.nameKey, name);
  }

  static String? getUserId() => _instance?.getString(SharedPrefKeys.userIdKey);
  static String? getUserName() => _instance?.getString(SharedPrefKeys.nameKey);
}
