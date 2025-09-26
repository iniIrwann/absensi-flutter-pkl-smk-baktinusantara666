import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Map<String, dynamic>>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = fetchNotifications();
  }

  String getDayName(String tanggal) {
    DateTime dateTime = DateTime.parse(tanggal);
    return DateFormat('EEEE', 'id_ID').format(dateTime);
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    try {
      final response = await http.get(Uri.parse(
          "http://localhost/API_CRUD/notification_logbook.php?userId=$userId"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["status"] == "success") {
          return (jsonData["notifications"] as List)
              .map((notif) => {
                    "id": int.tryParse(notif["id"].toString()) ?? 0,
                    "logbook_id": int.tryParse(notif["id"].toString()) ??
                        0, // Pastikan ini ada
                    "message": notif["message"] ?? "Tidak ada pesan",
                    "tanggal": notif["tanggal"] ?? "Belum ada tanggal",
                    "status_notif": notif["status_notif"] ?? "baru",
                  })
              .toList();
        }
      }
      throw Exception("Gagal mengambil notifikasi");
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    var url = Uri.parse("http://localhost/API_CRUD/update_notification.php");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "user_id": userId}),
      );

      var data = json.decode(response.body);
      if (data["status"] == "success") {
        setState(() {
          notificationsFuture = fetchNotifications();
        });
      }
    } catch (e) {
      debugPrint("Error updating notification: $e");
    }
  }

  void navigateToDetail(Map<String, dynamic> notif) {
    markAsRead(notif["id"]); // Tandai notifikasi sebagai dibaca

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogbookDetailScreen(logbookId: notif["id"]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada notifikasi baru"));
          }

          var notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notif = notifications[index];
              String hari = getDayName(notif['tanggal']);

              return InkWell(
                onTap: () =>
                    navigateToDetail(notif), // Navigasi ke halaman detail
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: notif["status_notif"] == "dibaca"
                        ? Colors.grey[200]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications,
                        color: notif["status_notif"] == "dibaca"
                            ? Colors.grey
                            : Colors.blue,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif["message"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif["status_notif"] == "dibaca"
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: notif["status_notif"] == "dibaca"
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              '$hari, ${notif["tanggal"]}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LogbookDetailScreen extends StatefulWidget {
  final int logbookId;

  const LogbookDetailScreen({super.key, required this.logbookId});

  @override
  _LogbookDetailScreenState createState() => _LogbookDetailScreenState();
}

class _LogbookDetailScreenState extends State<LogbookDetailScreen> {
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController kendalaController = TextEditingController();
  final TextEditingController solusiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLogbookDetail();
  }

  Future<void> fetchLogbookDetail() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost/API_CRUD/get_logbook_detail.php?logbookId=${widget.logbookId}'));
      print(widget.logbookId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tanggalController.text = data['logbook']['tanggal'] ?? '';
            waktuController.text = data['logbook']['waktu'] ?? '';
            kegiatanController.text = data['logbook']['kegiatan'] ?? '';
            kendalaController.text = data['logbook']['kendala'] ?? '';
            solusiController.text = data['logbook']['solusi'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching logbook details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Detail Log Book',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            TextFormField(
              controller: tanggalController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Tanggal", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: waktuController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Waktu", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: kegiatanController,
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Kegiatan", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: kendalaController,
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Kendala", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: solusiController,
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: "Solusi", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 5),
            const Text('Solusi tidak dapat diubah.',
                textAlign: TextAlign.start),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
