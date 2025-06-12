import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<bool> login(String email, String password) async {
    await _prefs.setString(_tokenKey, 'dummy_token');
    return true;
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
  }

  bool isLoggedIn() {
    return _prefs.getString(_tokenKey) != null;
  }
}
