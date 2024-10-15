import 'package:intl/intl.dart';

class CustomDateTime {
  static String getFormattedTime(DateTime dateTime) {
    // Format it to only show time like "1:53 PM"
    return DateFormat('h:mm a').format(dateTime);
  }
}
