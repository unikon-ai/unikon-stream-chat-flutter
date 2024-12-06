/// Custom event class to send events to the backend
class CustomEventType {
  /// Private constructor
  CustomEventType._();

  /// Event for chat info gets updated
  static const String chatInfoUpdated = 'chat_info_updated';

  /// Event for the user block or unblock
  /// Event for the restricted or un-restricted chat
  static const String blockUnblock = 'block_unblock';
}
