import 'package:dio/dio.dart';

import '../dto/login_dto.dart';
import 'base_api.dart';

abstract class IAuthenticationApi {
  Future<ApiDataResponse<LoginDto>> login(
      String email,
      String password,
      String? manufacture,
      String? model,
      String? sdk,
      String? deviceToken,
      String? versioncode,
      String? deviceId,
      String? brand,
      String? deviceType,
      {bool isPortalRequest = false});

  Future<ApiDataResponse<String>> forgotPassword(
      String email, String last4OfPhoneNumber);

  // Future<ApiDataResponse<PasswordResetTokenDto>> verifyPasswordResetCode(
  //     String code, String accessToken);

  // Future<ApiResponse> resetPassword(String id, String token, String password);
}

class AuthenticationApi extends BaseApi implements IAuthenticationApi {
  AuthenticationApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<LoginDto>> login(
      String email,
      String password,
      String? manufacture,
      String? model,
      String? sdk,
      String? deviceToken,
      String? versioncode,
      String? deviceId,
      String? brand,
      String? deviceType,
      {bool isPortalRequest = false}) async {
    return await wrapDataCall(() async {
      var response = await dio.post("/login",
          data: {
            'username': email,
            'password': password,
            'grant_type': "password",
            'manufacture': manufacture,
            'model': model,
            'sdk': sdk,
            'devicetoken': deviceToken,
            'versioncode': versioncode,
            'deviceid': deviceId,
            'brand': brand,
            'devicetype': deviceType,
            'isportalrequest': isPortalRequest
          },
          options: Options(contentType: Headers.formUrlEncodedContentType));
      return OkData(LoginDto.fromJson(response.data));
    });
  }

  @override
  Future<ApiDataResponse<String>> forgotPassword(
      String email, String last4OfPhoneNumber) async {
    return await wrapDataCall(() async {
      var result = await dio.post("/Passwords/ForgotPassword",
          data: {'email': email, 'phoneNumberDigits': last4OfPhoneNumber});
      return OkData(result.data["access_token"].toString());
    });
  }

  // Future<ApiDataResponse<PasswordResetTokenDto>> verifyPasswordResetCode(
  //     String code, String accessToken) async {
  //   return await wrapDataCall(() async {
  //     var result = await dio.post("/Passwords/VerifyResetCode",
  //         data: {'code': code},
  //         options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
  //     return OkData(PasswordResetTokenDto.fromJson(result.data));
  //   });
  // }

  // @override
  // Future<ApiResponse> resetPassword(
  //     String id, String token, String password) async {
  //   return await wrapCall(() async {
  //     await dio.post("/Passwords/ResetPassword",
  //         data: {'EmailGuid': id, 'Password': password, 'Token': token});
  //     return Ok();
  //   });
  // }
}
