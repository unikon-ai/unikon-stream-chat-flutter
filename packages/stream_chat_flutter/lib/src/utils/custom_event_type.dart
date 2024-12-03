/// Custom event class to send events to the backend
class CustomEventType {
  /// Private constructor
  CustomEventType._();

  /// Event for chat info gets updated
  static const String chatInfoUpdated = 'chat_info_updated';
}
