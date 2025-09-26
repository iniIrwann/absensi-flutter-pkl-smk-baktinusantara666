import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aplikasi_absensi/models/users.dart';
import 'package:aplikasi_absensi/models/absens.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'user_model.dart';

class ApiService {
  // Fetch many users
  Future<List<User>> fetchUsers(int userId) async {
    final response = await http.get(
        Uri.parse("http://localhost/API_CRUD/api_utama.php?userId=$userId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return [User.fromJson(data)]; // Jika objek, ubah jadi list
      } else if (data is List) {
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception("Unexpected JSON format");
      }
    } else {
      throw Exception("Failed to fetch user");
    }
  }

  // Fetch single user
  Future<User> fetchUser(int userID) async {
    if (userID <= 0) {
      throw Exception("Invalid user ID");
    }

    final response = await http
        .get(Uri.parse("http://localhost/API_CRUD/profile.php?userId=$userID"));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          return User.fromJson(data.first); // Ambil objek pertama dari list
        } else {
          throw Exception("User not found or invalid JSON format");
        }
      } catch (e) {
        throw Exception("Error parsing JSON: $e");
      }
    } else {
      throw Exception("Failed to fetch user: ${response.statusCode}");
    }
  }

  Future<Absensi?> fetchAbsensi(userId) async {
    final String url = 'http://localhost/API_CRUD/api_absen.php?userId=$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> absensiJson = jsonDecode(response.body);
        if (absensiJson.isNotEmpty) {
          return Absensi.fromJson(absensiJson[0]);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load absensi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
      return null; // Handle error
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final response =
        await http.get(Uri.parse('http://localhost/API_CRUD/announcement.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => {
                "id": item['id'],
                "tanggal": item['tanggal'],
                "title": item['title'],
                "isi_pengumuman": item['isi_pengumuman'],
                "pdf_url": item['pdf_url'],
              })
          .toList();
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  //get jammasuk homepage
  Future<Map<String, DateTime?>> fetchJamMasukDanKeluar(int userId) async {
    final response = await http.get(
        Uri.parse('http://localhost/API_CRUD/jam_masuk.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Jika jam_masuk atau jam_keluar null, kita kembalikan null
      if (data['jam_masuk'] == null && data['jam_keluar'] == null) {
        return {'jam_masuk': null, 'jam_keluar': null};
      }

      DateTime now = DateTime.now();

      DateTime? jamMasuk;
      if (data['jam_masuk'] != null) {
        String timeString = data['jam_masuk'];
        List<String> timeParts = timeString.split(':');
        jamMasuk = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
            int.parse(timeParts[2]));
      }

      DateTime? jamKeluar;
      if (data['jam_keluar'] != null) {
        String timeString = data['jam_keluar'];
        List<String> timeParts = timeString.split(':');
        jamKeluar = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
            int.parse(timeParts[2]));
      }

      return {'jam_masuk': jamMasuk, 'jam_keluar': jamKeluar};
    } else {
      throw Exception('Gagal mengambil data jam masuk dan keluar');
    }
  }

  //hitung absen
  Future<Map<String, dynamic>> fetchAbsensiData(userId) async {
    final response = await http.get(Uri.parse(
        'http://localhost/API_CRUD/hitung_absen.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        throw Exception(data["error"]);
      }
      return {
        'bulan': data['bulan'].toString(),
        'tahun': int.parse(data['tahun'].toString()),
        'hadir': int.tryParse(data['hadir'].toString()) ?? 0,
        'sakit': int.tryParse(data['sakit'].toString()) ?? 0,
        'izin': int.tryParse(data['izin'].toString()) ?? 0,
        'alpa': int.tryParse(data['alpa'].toString()) ?? 0,
      };
    } else {
      throw Exception('Failed to load absensi data');
    }
  }

  Future<Map<String, dynamic>> fetchTodayAbsen(int userId) async {
    final response = await http.get(Uri.parse(
        'http://localhost/API_CRUD/log_kehadiran.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey("success") && data["success"] == false) {
        return {
          'status': 'Belum Absen',
          'jam_masuk': '-',
          'jam_keluar': '-',
          'tanggal': DateTime.now()
              .toString()
              .substring(0, 10), // Gunakan tanggal hari ini
        };
      }

      if (data.containsKey("data") &&
          data["data"] is List &&
          data["data"].isNotEmpty) {
        final absenData = data["data"][0]; // Ambil elemen pertama dari array

        return {
          'status': absenData['status'] ?? 'Belum Absen',
          'jam_masuk': absenData['jam_masuk'] == "00:00:00"
              ? '-'
              : absenData['jam_masuk'].toString(),
          'jam_keluar': absenData['jam_keluar'] == "00:00:00"
              ? '-'
              : absenData['jam_keluar'].toString(),
          'tanggal': absenData['tanggal']?.toString(),
        };
      }
    }

    throw Exception('Failed to load absensi data');
  }

  Future<Map<String, String?>> getPengguna() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.containsKey('id') &&
        prefs.containsKey('username') &&
        prefs.containsKey('password');

    if (isLoggedIn) {
      return {
        'id': prefs.getString('id'),
        'nip': prefs.getString('NIP'),
        'nama': prefs.getString('Nama'),
        'jabatan': prefs.getString('Jabatan'),
        'Alamat': prefs.getString('Alamat'),
      };
    } else {
      return {}; // Kembalikan data kosong jika belum login
    }
  }
}
