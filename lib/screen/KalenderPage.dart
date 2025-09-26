import 'dart:convert';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aplikasi_absensi/screen/detail_kalender.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  late DateTime _selectedDate;
  late List<DateTime> _eventDates;
  bool _isLoading = false; // Indikator loading

  // Daftar kegiatan yang akan ditampilkan berdasarkan tanggal yang dipilih
  List<Map<String, dynamic>> _kegiatanTampil = [];

  // Daftar kegiatan mendatang (Incoming Schedule)
  List<Map<String, dynamic>> _incomingSchedule = [];

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now();
    _eventDates = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan hanya memanggil update setelah layout selesai
      _updateKegiatan();
    });
  }

  // Fungsi untuk mengambil data dari API berdasarkan tanggal
  Future<void> _updateKegiatan() async {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _isLoading = true; // Menampilkan indikator loading
    });

    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost/API_CRUD/kalender.php?tanggal=$formattedDate"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _kegiatanTampil = (data['data'] as List)
                .map((item) => {
                      "tanggal": item["tanggal"],
                      "title": item["judul_kegiatan"],
                      "description": item["isi_kegiatan"]
                    })
                .toList();
          });
        } else {
          setState(() {
            _kegiatanTampil = [];
          });
        }
      } else {
        if (kDebugMode) {
          debugPrint("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Gagal mengambil data: $e");
      }
    } finally {
      setState(() {
        _isLoading = false; // Menyembunyikan indikator loading
      });
    }

    // Update incoming schedule (jadwal mendatang)
    _updateIncomingSchedule();
  }

  Future<void> _updateIncomingSchedule() async {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost/API_CRUD/kalender.php?incoming_schedule=true&tanggal=$formattedDate"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _incomingSchedule = (data['data'] as List)
                .where((item) {
                  // Filter kegiatan yang memiliki tanggal lebih besar dari tanggal yang dipilih
                  DateTime eventDate = DateTime.parse(item['tanggal']);
                  return eventDate.isAtSameMomentAs(_selectedDate) ||
                      eventDate.isAfter(_selectedDate);
                })
                .map((item) => {
                      "tanggal": item["tanggal"],
                      "title": item["judul_kegiatan"],
                      "description": item["isi_kegiatan"]
                    })
                .toList();
          });
        } else {
          setState(() {
            _incomingSchedule = [];
          });
        }
      } else {
        if (kDebugMode) {
          debugPrint("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Gagal mengambil data: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Kalender',
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0),
            //   child: Text('2025', style: TextStyle(color: Color(0xFF1769FF), fontSize: 30, fontWeight: FontWeight.bold),),
            // ),
            const SizedBox(height: 10),
            CalendarTimeline(
              // showYears: true,
              initialDate: _selectedDate,
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2025, 12, 31),
              eventDates: _eventDates,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
                _updateKegiatan();
              },
              leftMargin: 12,
              monthColor: Colors.black,
              dayColor: Colors.black,
              dayNameColor: Colors.white,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Color(0xFF1769FF),
              dotColor: Colors.white,
              locale: 'id',
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Kegiatan Hari ini',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Current kegiatan
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _kegiatanTampil.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          itemCount: _kegiatanTampil.length,
                          itemBuilder: (context, index) {
                            return _buildKegiatanCard(
                              _kegiatanTampil[index]['tanggal']!,
                              _kegiatanTampil[index]['title']!,
                              _kegiatanTampil[index]['description']!,
                            );
                          },
                        )
                      : SizedBox(
                          height:
                              150, // Batas tinggi untuk "Tidak ada kegiatan"
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Tidak ada kegiatan pada tanggal ini",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[200], // Warna divider
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Incoming Schedule',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            //incoming schedule
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _incomingSchedule.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          itemCount: _incomingSchedule.length,
                          itemBuilder: (context, index) {
                            return _buildIncoming(
                              _incomingSchedule[index]['tanggal']!,
                              _incomingSchedule[index]['title']!,
                              _incomingSchedule[index]['description']!,
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Tidak ada jadwal mendatang",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToAnnouncement(Map data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKalender(ListData: data),
      ),
    );
  }

  Widget _buildKegiatanCard(String tanggal, title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          _navigateToAnnouncement({
            "tanggal": tanggal,
            "title": title,
            "description": description,
            // "pdf_url": pdf,
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncoming(tanggal, String title, String description) {
    return InkWell(
      onTap: () {
        _navigateToAnnouncement({
          "tanggal": tanggal,
          "title": title,
          "description": description,
          // "pdf_url": pdf,
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    tanggal,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
