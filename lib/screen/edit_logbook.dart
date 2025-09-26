// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Tambahkan untuk parsing response JSON

class EditDataPage extends StatefulWidget {
  final Map ListData;

  const EditDataPage({super.key, required this.ListData});

  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController user_id;
  late TextEditingController tanggal;
  late TextEditingController waktu;
  late TextEditingController kegiatan;
  late TextEditingController kendala;
  late TextEditingController solusi;

  @override
  void initState() {
    super.initState();
    user_id =
        TextEditingController(text: widget.ListData['user_id'].toString());
    tanggal =
        TextEditingController(text: widget.ListData['tanggal'].toString());
    waktu = TextEditingController(text: widget.ListData['waktu'].toString());
    kegiatan = TextEditingController(text: widget.ListData['kegiatan']);
    kendala = TextEditingController(text: widget.ListData['kendala']);
    solusi = TextEditingController(text: widget.ListData['solusi']);
  }

  @override
  void dispose() {
    user_id.dispose();
    tanggal.dispose();
    waktu.dispose();
    kegiatan.dispose();
    kendala.dispose();
    super.dispose();
  }

  Future<bool> _update() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/API_CRUD/edit_logbook.php"),
        body: {
          "user_id": user_id.text,
          "tanggal": tanggal.text,
          "waktu": waktu.text,
          "kegiatan": kegiatan.text,
          "kendala": kendala.text,
          "solusi": solusi.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error: $e");
      } // Debugging error
      return false;
    }
  }

  void _showSnackbar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.start,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Jika sukses, kembali ke halaman sebelumnya dengan status true
    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Log Book',
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
        padding: const EdgeInsets.all(15),
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  readOnly: true,
                  enabled: false,
                  controller: tanggal,
                  decoration: const InputDecoration(
                    labelText: "Tanggal",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Tanggal tidak boleh kosong" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: waktu,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Waktu",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                              alwaysUse24HourFormat: true), // Paksa 24 jam
                          child: child!,
                        );
                      },
                    );

                    if (pickedTime != null) {
                      DateTime now = DateTime.now();
                      String formattedTime =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:"
                          "${pickedTime.minute.toString().padLeft(2, '0')}:"
                          "${now.second.toString().padLeft(2, '0')}"; // Tambahkan detik

                      setState(() {
                        waktu.text = formattedTime;
                      });
                    }
                  },
                  validator: (value) =>
                      value!.isEmpty ? "Waktu tidak boleh kosong" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  maxLines: 5,
                  controller: kegiatan,
                  decoration: InputDecoration(
                    labelText: "Kegiatan",
                    border: OutlineInputBorder(),
                    focusColor: Colors.blue,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Kegiatan tidak boleh kosong" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  maxLines: 5,
                  controller: kendala,
                  decoration: InputDecoration(
                    labelText: "Kendala",
                    border: OutlineInputBorder(),
                    focusColor: Colors.blue,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Kendala tidak boleh kosong" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  readOnly: true,
                  maxLines: 5,
                  controller: solusi,
                  decoration: InputDecoration(
                    labelText: "Solusi yg diberikan :",
                    border: OutlineInputBorder(),
                    focusColor: Colors.blue,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solusi tidak dapat diubah.',
                        textAlign: TextAlign.start),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        bool success = await _update();
                        _showSnackbar(
                          success
                              ? "Data berhasil diupdate"
                              : "Gagal update data / Tidak ada perubahan",
                          success,
                        );
                      }
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
