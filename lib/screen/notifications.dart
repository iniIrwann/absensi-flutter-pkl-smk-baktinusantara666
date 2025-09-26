import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService with ChangeNotifier {
  int unreadCount = 0;
  Timer? _timer;

  NotificationService() {
    startPolling();
  }

  void startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await checkNotification();
    });
  }

  Future<void> checkNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    try {
      var url = Uri.parse(
          "http://localhost/API_CRUD/get_notifications.php?userId=$userId");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success' && data.containsKey('jumlah')) {
          unreadCount = data['jumlah']; // Ambil jumlah notifikasi
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error polling: $e");
      }
    }
  }

  void markAsRead(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    var url = Uri.parse("http://localhost/API_CRUD/update_notification.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id": id,
        "user_id": userId,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        unreadCount = (unreadCount > 0) ? unreadCount - 1 : 0;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
