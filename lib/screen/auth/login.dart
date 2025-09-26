import 'package:aplikasi_absensi/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_absensi/bottomnav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_absensi/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  void _loadSavedLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
    });
    AuthService authService = AuthService();
    Map<String, String?> loginData = await authService.getLogin();

    if (loginData['email'] != null) {
      setState(() {
        username.text = loginData['email']!;
        password.text = loginData['password']!;
      });
    }
  }

  void _saveRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    setState(() {
      rememberMe = value;
    });
  }

  Future<void> login() async {
    if (rememberMe) {
      AuthService().saveLogin(username.text, password.text);
    }

    if (username.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username dan Password tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var response = await http.post(
      Uri.parse("http://localhost/API_CRUD/login.php"),
      body: {
        "username": username.text,
        "password": password.text,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'Success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', username.text);
        await prefs.setString('password', password.text);
        await prefs.setString('id', data['id'].toString());
        await prefs.setString('NIP', data['NIP']);
        await prefs.setString('nama_depan', data['nama_depan']);
        await prefs.setString('Nama', data['Nama']);
        await prefs.setString('Jabatan', data['Jabatan']);
        await prefs.setString('Alamat', data['Alamat']);
        await prefs.setString('profile_picture', data['profile_picture']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login Success'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bottomnav()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Username atau password salah'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Terjadi kesalahan saat login'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo-agp.jpg', // Replace with your logo asset
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Log In\nPresensi Online',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Username Field
                TextField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password Field
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (newValue) {
                            _saveRememberMe(newValue ?? false);
                          },
                        ),
                        Text(
                          'Remember Me?',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OnboardingScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                            fontSize: 14, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
