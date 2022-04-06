import 'package:shared_preferences/shared_preferences.dart';

abstract class ITokenStore {
  Future<String?> load();

  Future save(String accessToken);

  Future delete();

  Future<bool> isLoggedIn();
}

class TokenStore extends ITokenStore {
  final SharedPreferences _sharedPreferences;
  static const String accessToken = 'access_token';

  TokenStore(this._sharedPreferences);

  @override
  Future delete() async {
    await _sharedPreferences.remove(accessToken);
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return _sharedPreferences.containsKey(accessToken);
    } finally {}
  }

  @override
  Future<String?> load() async {
    return _sharedPreferences.getString(accessToken);
  }

  @override
  Future save(String accessToken) async {
    await _sharedPreferences.setString(accessToken, accessToken);
  }
}
