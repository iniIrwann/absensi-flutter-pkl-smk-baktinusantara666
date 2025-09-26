import 'package:aplikasi_absensi/screen/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  Future<void> _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await Future.delayed(Duration(milliseconds: 500)); // Tambahkan jeda kecil

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  final TextStyle _titleStyle = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.white70,
    height: 1.5,
  );

  List<Widget> _buildPageIndicator() {
    return List.generate(
        _numPages, (index) => _indicator(index == _currentPage));
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: isActive ? 24.0 : 12.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _onSkip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onNext() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      _completeOnboarding(context);
    }
  }

  Widget _buildPage(String imagePath, String title, String subtitle) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 4, // 40% untuk gambar
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
        Expanded(
          flex: 6, // 60% untuk teks
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.start, // Teks langsung menempel ke gambar
              children: <Widget>[
                Text(title, style: _titleStyle),
                Text(subtitle, style: _subtitleStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF42A5F5), // Warna biru terang dari homepage
                Color(0xFF1E6FFF), // Warna transisi agar lebih halus
                Color(0xFF0051FF), // Warna biru tua dari homepage
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() => _currentPage = page);
                    },
                    children: <Widget>[
                      _buildPage(
                        'assets/images/onboarding0.png',
                        // 'images/onboarding0.png',
                        'Manage Attendance Easily',
                        'Aplikasi absensi online berfungsi untuk mencatat, mengelola, dan memantau kehadiran secara digital. Aplikasi ini meningkatkan efisiensi, dan memudahkan manajemen kehadiran dibandingkan sistem manual.',
                      ),
                      _buildPage(
                        'assets/images/onboarding1.png',
                        // 'images/onboarding1.png',
                        'Digital Map Integration for Accurate Attendance',
                        'Aplikasi absensi digital dengan integrasi peta mencatat kehadiran secara akurat, mendukung absensi di lokasi kerja 1, lokasi kerja 2, atau WFH dengan efisien dan real-time.',
                      ),
                      _buildPage(
                        'assets/images/onboarding2.png',
                        // 'images/onboarding2.png',
                        'Get a new experience\nof imagination',
                        'Rasakan pengalaman baru dengan cara yang belum pernah ada sebelumnya.',
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                if (_currentPage != _numPages - 1)
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.0, right: 5.0, bottom: 0.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: _onNext,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 100.0,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: _onSkip,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Get started',
                      style: TextStyle(
                        color: Color(0xFF0051FF),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
