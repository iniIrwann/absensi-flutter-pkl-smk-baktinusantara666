import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Simpan Login
  Future<void> saveLogin(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('remember_me', true);
  }

  // Ambil Data Login
  Future<Map<String, String?>> getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      return {
        'email': prefs.getString('email'),
        'password': prefs.getString('password'),
      };
    }
    return {'email': null, 'password': null};
  }

  // Logout (Hapus Data)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
