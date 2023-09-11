import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberUtility {
  static const String region = 'US';
  static Future<bool> validatePhoneNumber({required String phoneNumber}) async {
    try {
      PhoneNumber number =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, region);
      return number.isoCode == region;
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<String> parseToE164Format({required String phoneNumber}) async {
    try {
      PhoneNumber number =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, region);
      return number.phoneNumber.toString();
    } catch (e) {
      return Future.value(phoneNumber);
    }
  }
}
