import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberUtility {
  static const String usRegion = 'US';
  static const String canadaRegion = 'CA';
  static Future<bool> validatePhoneNumber({required String phoneNumber}) async {
    try {
      PhoneNumber number =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, usRegion);
      return number.isoCode == usRegion || number.isoCode == canadaRegion;
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<String> parseToE164Format({required String phoneNumber}) async {
    try {
      PhoneNumber number =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, usRegion);
      return number.phoneNumber.toString();
    } catch (e) {
      return Future.value(phoneNumber);
    }
  }
}
