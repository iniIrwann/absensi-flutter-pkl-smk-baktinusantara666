import 'dart:async';
import 'package:aplikasi_absensi/screen/auth/login.dart';
import 'package:aplikasi_absensi/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

    await Future.delayed(Duration(seconds: 2)); // Simulasi loading splash screen

    if (onboardingDone) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/logo-agp.jpg', width: 200),
      ),
    );
  }
}
