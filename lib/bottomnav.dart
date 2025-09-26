import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:aplikasi_absensi/screen/HomePage2.dart';
import 'package:aplikasi_absensi/screen/profile.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Bottomnav extends StatelessWidget {
  const Bottomnav({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: MainScreen(),
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

  // Daftar halaman berdasarkan indeks
  final List<Widget> _pages = [
    Homepage2(),
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
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai indeks
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color.fromARGB(255, 209, 209, 209),
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
