import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_absensi/models/users.dart';
import 'package:aplikasi_absensi/screen/auth/logout.dart';
import 'package:aplikasi_absensi/screen/edit_profile.dart';
import 'package:aplikasi_absensi/service/api_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = Future.error('Users not loaded');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0'); // Konversi ke int

    if (userId != null) {
      setState(() {
        _userFuture =
            ApiService().fetchUser(userId); // Ambil data user berdasarkan ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(IconlyLight.logout), // Trailing (sebelah kanan)
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Logout(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No users found"));
            }

            // Ambil data pengguna pertama (jika ada)
            User user = snapshot.data!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      // ignore: unnecessary_null_comparison
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl)
                          : const AssetImage('images/letter.png')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        //button edit
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                    user:
                                        user), // Pass the user object to the next page
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NIP: ${user.nip}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Office Position: ${user.jabatan}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  user.alamat,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
