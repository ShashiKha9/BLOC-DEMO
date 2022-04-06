import 'package:shared_preferences/shared_preferences.dart';

abstract class IDataManager {
  Future<void> clearAll();
}

class DataManager implements IDataManager {
  final SharedPreferences _sharedPreferences;

  DataManager(this._sharedPreferences);

  @override
  Future<void> clearAll() async {
    await _sharedPreferences.clear();
  }
}
