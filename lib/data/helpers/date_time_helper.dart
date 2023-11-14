import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper();

  static String convertToString(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
  }

  static DateTime convertToDateTime(String dateTime) {
    return DateFormat("MM/dd/yyyy hh:mm:ss aaa").parse(dateTime);
  }

  static String forDispatchDetails(DateTime dateTime) {
    return DateFormat("MM/dd/yyyy hh:mm:ss aa").format(dateTime);
  }

  static DateTime convertToStandard(String timeStamp) {
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStamp);
    } on FormatException {
      //todo check this
      return DateFormat("MM/dd/yyyy hh:mm:ss aaa").parse(timeStamp);
    }
  }

  ///get ISO time String from DateTime
  ///Output: 2020-09-16T20:42:38.629+05:30
  static String toISOTimeString(DateTime? dateTime) {
    var date = dateTime ?? DateTime.now();
    //Time zone may be null in dateTime hence get timezone by  dateTime
    var duration = DateTime.now().timeZoneOffset;
    if (duration.isNegative) {
      return (date.toIso8601String() +
          "-${duration.inHours.abs().toString().padLeft(2, '0')}:${(duration.inMinutes.abs() - (duration.inHours.abs() * 60)).toString().padLeft(2, '0')}");
    } else {
      return (date.toIso8601String() +
          "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }
  }
}
