// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:info_widget/info_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aplikasi_absensi/screen/logKehadiran.dart';
import 'package:aplikasi_absensi/models/users.dart';
import 'package:aplikasi_absensi/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class ClockIn extends StatefulWidget {
  const ClockIn({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<ClockIn> {
  String formattedDate =
      DateFormat('EEEE dd MMM yyyy', 'id_ID').format(DateTime.now());
  bool? isWFH = false;
  LatLng? currentLocation; // Default location
  String? currentAddress; // Untuk menyimpan alamat
  List<LatLng> circlePoints = [];
  List<LatLng> circlePoints2 = [];
  final double radiusInMeters = 2000;
  final LatLng centerPoint =
      // LatLng(-6.941592860499105, 107.74023920706921); // lokasi bn
      // LatLng(-6.9338097, 107.6274626); // lokasi bn (random)
      // LatLng(-6.9173248, 107.6854784); // lokasi home
      // LatLng(-6.948433357503519, 107.76992131459025); // lokasi home
      LatLng(-6.932383627819049, 107.62358372818412); // lokasi agp
  final LatLng centerPoint2 = LatLng(-6.929274460238826, 107.6251876650562);

  late Future<User> _usersFuture;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _usersFuture = Future.error("User not loaded");
    _loadUserData();
    circlePoints = _generateCirclePoints(centerPoint, radiusInMeters, 360);
    circlePoints2 = _generateCirclePoints(centerPoint2, radiusInMeters, 360);
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    if (userId != null) {
      setState(() {
        _usersFuture = ApiService().fetchUser(userId);
      });
    }
  }

  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // debugPrint("Type of connectivityResult: ${connectivityResult.runtimeType}");
    // debugPrint("Value of connectivityResult: $connectivityResult");
    return connectivityResult != ConnectivityResult.none;
  }

  // Fungsi untuk mendapatkan alamat dari latlng koordinat
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    if (!await _isConnected()) {
      _showSnackbar('Tidak ada koneksi internet.', Colors.red);
      return;
    }

    // debugPrint("Koordinat: $latitude, $longitude");
    try {
      final response = await http.get(
        Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] as String?;
        setState(() {
          currentAddress = address ?? "Alamat tidak ditemukan.";
        });
        // debugPrint("Alamat ditemukan: $currentAddress");
      } else {
        setState(() {
          currentAddress = "Alamat tidak ditemukan.";
        });
        // debugPrint("Gagal mendapatkan alamat dari API.");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Exception: $e");
      }
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // Fungsi untuk menentukan lokasi pengguna
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar(
          'Layanan lokasi tidak aktif. Aktifkan GPS Anda.', Colors.red);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Izin lokasi ditolak.', Colors.red);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Izin lokasi ditolak secara permanen.', Colors.red);
      return;
    }

    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      // Position position = await Geolocator.getCurrentPosition(
      //   accuracy: LocationAccuracy.best,
      //   timeLimit: Duration(seconds: 10),
      // );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Panggil untuk mendapatkan alamat
      _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error getting location: $e");
      }
      _showSnackbar('Gagal mendapatkan lokasi dalam 10 detik: $e', Colors.red);
    }
  }

  // Fungsi untuk menghasilkan titik di sekitar pusat lingkaran
  List<LatLng> _generateCirclePoints(
      LatLng center, double radiusInMeters, int points) {
    List<LatLng> circlePoints = [];
    double radiusInDegrees =
        radiusInMeters / 6371000; // Menghitung jarak dalam derajat

    for (int i = 0; i < points; i++) {
      double angle =
          (i * (360 / points)) * math.pi / 180; // Menghitung sudut dalam radian
      double latitude = center.latitude + (radiusInDegrees * math.cos(angle));
      double longitude = center.longitude +
          (radiusInDegrees *
              math.sin(angle) /
              math.cos(center.latitude * math.pi / 180));

      circlePoints.add(LatLng(latitude, longitude));
    }
    return circlePoints;
  }

  //API Create Absen
  void _submitAbsensi(
      bool isSuccess, LatLng userLocation, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');
    final String apiUrl =
        "http://localhost/API_CRUD/absensi.php"; // Sesuaikan URL API Anda

    Map<String, dynamic> data = {
      "user_id": userId, // Sesuaikan dengan ID user yang sesuai
      "wfh": isWFH == true ? "WFH" : "Berada di sekitar kantor",
      // "lokasi_kantor": currentAddress.toString() ?? 'Tidak ditemukan',
      "latitude": userLocation.latitude.toString(),
      "longitude": userLocation.longitude.toString(),
      "status": status.toString(), // Status absensi: "Hadir" atau "Keluar"
    };
    // debugPrint("Data yang dikirim: ${json.encode(data)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Cek apakah response.body kosong atau tidak
        if (response.body.isEmpty) {
          // debugPrint("Respons kosong");
          _showSnackbar('Terjadi kesalahan. Coba lagi.', Colors.red);
          return;
        }

        try {
          final responseData = jsonDecode(response.body);
          if (responseData['message']
              .contains('tidak dapat melakukan absensi masuk')) {
            _showSnackbar(
                responseData[
                    'message'], // Use the message returned from the server
                Colors.red);
          } else if (responseData['message'] ==
              "Anda sudah melakukan absensi pada hari ini.") {
            _showSnackbar('Anda sudah melakukan absensi hari ini.', Colors.red);
          } else if (responseData['message'] ==
              "Anda harus mengisi logbook terlebih dahulu sebelum clock out.") {
            _showSnackbar(
                'Anda harus mengisi logbook terlebih dahulu sebelum clock out.',
                const Color.fromARGB(255, 255, 170, 0));
          } else {
            _showSnackbar(responseData['message'], Colors.green);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error decoding JSON: $e");
          }
          _showSnackbar(
              'Terjadi kesalahan saat memproses data. Coba lagi.', Colors.red);
        }
      } else {
        _showSnackbar('Gagal mengirim absensi: ${response.body}', Colors.red);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error saat mengirim absensi: $e");
      }
      _showSnackbar('Terjadi kesalahan. Coba lagi.', Colors.red);
    }
  }

  bool _isInsideCircle(LatLng point, LatLng center, double radius) {
    final Distance distance = Distance();
    double distanceInMeters = distance.as(LengthUnit.Meter, point, center);
    return distanceInMeters <= radius;
  }

  void _markAttendance(String status) {
    if (currentLocation == null) {
      _showSnackbar('Gagal mendeteksi lokasi. Coba lagi!', Colors.red);
      return;
    }
    LatLng userLocation = currentLocation!;

    if (_isInsideCircle(userLocation, centerPoint, radiusInMeters)) {
      _showSnackbar('Anda berada dalam area kerja 1.', Colors.green);
      _submitAbsensi(true, userLocation, status);
    } else if (_isInsideCircle(userLocation, centerPoint2, radiusInMeters)) {
      _showSnackbar('Anda berada dalam area kerja 2.', Colors.green);
      _submitAbsensi(true, userLocation, status);
    } else if (isWFH == true) {
      _showSnackbar('Anda memilih opsi WFH', Colors.green);
      _submitAbsensi(true, userLocation, status);
    } else {
      _showSnackbar('Anda berada di luar area yang ditentukan.', Colors.red);
    }
  }

  // Fungsi untuk menampilkan pesan Snackbar
  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan shadow bawaan
        title: Text(
          'Absensi',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            height: 1,
            color: Colors.grey[300], // Warna divider lebih halus
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
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200], // Warna divider
          ),
          // Informasi Tanggal dan Waktu tepat di atas maps
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 10, top: 10),
                child: Row(
                  children: [
                    Icon(
                      IconlyLight.calendar,
                      size: 30,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ini - $formattedDate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Shift Regular Office (08.00-15.00)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Map
              currentLocation == null
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 293,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: currentLocation!,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          if (currentLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: currentLocation!,
                                  width: 50.0,
                                  height: 50.0,
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                    // ),
                                  ),
                                ),
                              ],
                            ),
                          PolygonLayer(
                            polygons: [
                              Polygon(
                                points: circlePoints,
                                color: Colors.blue.withOpacity(0.3),
                                borderColor: Colors.blue,
                                borderStrokeWidth: 2.0,
                              ),
                              Polygon(
                                points: circlePoints2,
                                color: Colors.green.withOpacity(0.3),
                                borderColor: Colors.green,
                                borderStrokeWidth: 2.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          // Address and Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Saya',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  currentAddress ?? 'Menunggu alamat...',
                  style: TextStyle(color: Colors.black54, fontSize: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isWFH,
                          onChanged: (bool? value) {
                            setState(() {
                              isWFH = value;
                            });
                          },
                        ),
                        Text(
                          "Work From Home",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    InfoWidget(
                      infoTextStyle: TextStyle(
                        backgroundColor: Colors.grey[100],
                      ),
                      infoText:
                          "Work From Home (WFH) adalah opsi absensi yang memungkinkan karyawan bekerja dari rumah atau lokasi lain di luar kantor.\nJika Anda memilih opsi ini, sistem akan mencatat bahwa Anda sedang bekerja secara remote dan tidak perlu berada di sekitar area kantor untuk melakukan absensi.\nPastikan untuk mengaktifkan opsi ini jika Anda bekerja dari rumah hari ini.",
                      iconData: Icons.info,
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _markAttendance("Hadir");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Column(
                        children: [
                          Text('Clock In',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Text('08.00 WIB', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _markAttendance("Keluar");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Column(
                        children: [
                          Text('Clock Out',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Text('15.00 WIB', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogKehadiran()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                    ),
                    child: Text(
                      'Lihat Rekap Absensi',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
