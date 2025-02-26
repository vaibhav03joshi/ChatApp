import 'package:shared_preferences/shared_preferences.dart';

class PrefsFunction {
  Future<void> setInitialPrefs(
      String name, String email, String number, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("number", number);
    prefs.setString("password", password);
    prefs.setBool("isLogin", true);
  }

  Future<void> resetPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
