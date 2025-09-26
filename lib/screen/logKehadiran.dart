import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_absensi/models/users.dart';
import 'package:aplikasi_absensi/screen/fiturutama2.dart';
import 'package:aplikasi_absensi/service/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogKehadiran(),
    );
  }
}

class LogKehadiran extends StatefulWidget {
  const LogKehadiran({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogKehadiran createState() => _LogKehadiran();
}

class _LogKehadiran extends State<LogKehadiran> {
  late Future<User> _usersFuture;
  late Future<Map<String, dynamic>> _absensiDataFuture;
  late Future<Map<String, dynamic>> _todayAbsensi;

  @override
  void initState() {
    super.initState();
    _usersFuture = Future.error("User not loaded");
    _absensiDataFuture = Future.value({});
    _todayAbsensi = Future.value({});
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0'); // Konversi ke int

    if (userId != null) {
      setState(() {
        _usersFuture =
            ApiService().fetchUser(userId); // Ambil data user berdasarkan ID
        _absensiDataFuture = ApiService().fetchAbsensiData(userId);
        _todayAbsensi = ApiService().fetchTodayAbsen(userId);
      });
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle; // Green checkmark for "Hadir"
      case 'sakit':
        return Icons.sick; // Sick icon for "Sakit"
      case 'izin':
        return Icons.event_busy; // Calendar icon for "Izin"
      case 'alpha':
        return Icons.cancel; // Red cancel icon for "Alpha"
      default:
        return Icons.info; // Default icon
    }
  }

  String getDayName(String tanggal) {
    DateTime dateTime = DateTime.parse(tanggal);
    return DateFormat('EEEE', 'id_ID').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Log Kehadiran',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Tinggi divider
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200], // Warna divider
          ),
        ),
      ),
      body: ListView(
        children: [
          // Profil Section
          FutureBuilder<User>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "No users found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else {
                User user = snapshot.data!;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 66, 165, 245),
                        Color.fromARGB(255, 0, 81, 255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user.imageUrl),
                        onBackgroundImageError: (_, __) =>
                            Icon(Icons.error, size: 40, color: Colors.white),
                      ),
                      SizedBox(width: 16),

                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name, // Display the user name
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'NIP: ${user.nip}', // User ID or other info
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              user.jabatan, // User position or job title
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Fetch and display absensi data
          FutureBuilder<Map<String, dynamic>>(
            future: _absensiDataFuture, // Use the absensi data Future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No absensi data found"));
              } else {
                var absensiData = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Montserrat",
                            color: Colors
                                .black87, // Warna default untuk teks utama
                          ),
                          children: [
                            TextSpan(text: 'Total Kehadiran / '), // Teks utama
                            TextSpan(
                              text: '${absensiData['bulan']}', // Nama bulan
                              style: TextStyle(
                                  color: Colors.grey), // Warna teks bulan
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusCard(
                            color: Colors.green,
                            title: 'Hadir',
                            count: '${absensiData['hadir']}x',
                          ),
                          _buildStatusCard(
                            color: Colors.red,
                            title: 'Sakit',
                            count: '${absensiData['sakit']}x',
                          ),
                          _buildStatusCard(
                            color: Colors.orange,
                            title: 'Izin',
                            count: '${absensiData['izin']}x',
                          ),
                          _buildStatusCard(
                            color: Colors.grey,
                            title: 'Alpha',
                            count: '${absensiData['alpa']}x',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          FutureBuilder<Map<String, dynamic>>(
              future: _todayAbsensi, // Use the absensi data Future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No absensi data found"));
                } else {
                  var absensiData = snapshot.data!;
                  String hari =
                      getDayName(absensiData['tanggal'] ?? "2025-01-01");
                  return Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'Aktifitas Hari ini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (absensiData['status'] == 'Hadir') ...[
                          attendanceCard(
                            icon: Icons.login,
                            title: "Check In",
                            time: absensiData['jam_masuk'] != null
                                ? "${absensiData['jam_masuk']} WIB"
                                : "-",
                            date: absensiData['tanggal'] != null
                                ? "$hari, ${absensiData['tanggal']}"
                                : "-",
                          ),
                          SizedBox(height: 12),
                          if (absensiData['jam_keluar'] != 'null') ...[
                            attendanceCard(
                              icon: Icons.logout,
                              title: "Check Out",
                              time: absensiData['jam_keluar'] == "null"
                                  ? "00:00 WIB"
                                  : "${absensiData['jam_keluar']} WIB",
                              date: absensiData['tanggal'] != null
                                  ? "$hari, ${absensiData['tanggal']}"
                                  : "-",
                            ),
                          ]
                        ] else if ([
                          "Izin",
                          "Sakit",
                          "Alpha",
                          "Keperluan lain",
                          "Lainnya"
                        ].contains(absensiData['status'])) ...[
                          Center(
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: Colors.orange.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline, // Ikon informasi
                                      color: Colors.orange,
                                      size: 48,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Status Absensi",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Anda ${absensiData['status']} pada hari ini.",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (absensiData['keterangan'] != null &&
                                        absensiData['keterangan']
                                            .toString()
                                            .isNotEmpty) ...[
                                      SizedBox(height: 8),
                                      Text(
                                        "Keterangan: ${absensiData['keterangan']}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    SizedBox(height: 15),
                                    // ElevatedButton.icon(
                                    //   onPressed: () {
                                    //     // Aksi misalnya membuka halaman absensi
                                    //   },
                                    //   icon: Icon(Icons.history),
                                    //   label: Text("Lihat Riwayat"),
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.orange,
                                    //     foregroundColor: Colors.white,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //     padding: EdgeInsets.symmetric(
                                    //         horizontal: 20, vertical: 12),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: Colors.redAccent.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                      size: 48,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Belum ada absensi hari ini",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Silakan absen sekarang untuk mencatat kehadiran Anda.",
                                      style: TextStyle(color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 15),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ClockIn()),
                                        );
                                      },
                                      label: Text("Absen Sekarang"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget attendanceCard({
    required IconData icon,
    required String title,
    required String time,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50, // Light blue gradient start
            Colors.blue.shade100, // Light blue gradient end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade200, // Background color for the icon
              shape: BoxShape.circle, // Circular container for the icon
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white, // White icon for contrast
            ),
          ),
          const SizedBox(width: 16), // Spacing between icon and text

          // Title and Date Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800, // Dark blue for emphasis
                  ),
                ),
                const SizedBox(height: 4), // Spacing between title and date
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600, // Light grey for secondary text
                  ),
                ),
              ],
            ),
          ),

          // Time and Status Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800, // Dark blue for emphasis
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required Color color,
    required String title,
    required String count,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      // width: 100, // Adjust width for better spacing
      // height: 120, // Increase height for better proportions
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9), // Slightly transparent gradient start
            color.withOpacity(0.7), // Slightly transparent gradient end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon for visual representation
          Icon(
            _getStatusIcon(title), // Dynamically assign icons based on status
            size: 36,
            color: Colors.white,
          ),
          const SizedBox(height: 8), // Spacing between icon and text
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4), // Spacing between count and title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
