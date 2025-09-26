import 'package:aplikasi_absensi/screen/auth/login.dart';
import 'package:aplikasi_absensi/screen/onboarding.dart';
import 'package:aplikasi_absensi/screen/HomePage2.dart';
import 'package:aplikasi_absensi/screen/notifications.dart';
import 'package:aplikasi_absensi/screen/profile.dart';
import 'package:aplikasi_absensi/screen/auth/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('id', 'ID'), // Bahasa Indonesia locale
      ],
      title: 'Aplikasi Absensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: SplashScreen(),
      initialRoute: '/', // Mulai dari splash screen
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginPage(),
        '/main': (context) =>
            MainScreen(), // Arahkan ke MainScreen setelah SplashScreen
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage2(), // Perbaiki huruf besar kecilnya
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(255, 209, 209, 209),
              width: 1,
            ),
          ),
        ),
        child: SalomonBottomBar(
          backgroundColor: Colors.grey[100],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            SalomonBottomBarItem(
              icon: Icon(IconlyLight.home, size: 30),
              title: Text('Home'),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: Icon(IconlyLight.profile, size: 30),
              title: Text('Profile'),
              selectedColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
