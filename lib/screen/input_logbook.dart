import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class InputLogbook extends StatefulWidget {
  const InputLogbook({super.key});

  @override
  _InputLogbookState createState() => _InputLogbookState();
}

class _InputLogbookState extends State<InputLogbook> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _activityController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');
    final date = _dateController.text;
    final activity = _activityController.text;
    final problem = _problemController.text;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan user ID, silakan login ulang!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (date.isEmpty || activity.isEmpty || problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua inputan harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final url = Uri.parse(
          'http://localhost/API_CRUD/add_logbook.php'); // Ganti dengan URL API PHP Anda

      final response = await http.post(
        url,
        body: {
          'user_id': userId.toString(),
          'date': date,
          'activity': activity,
          'problem': problem,
        },
      );
      // debugPrint('Response headers: ${response.headers}');
      // debugPrint('Response body: ${response.body}');

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['message'] == "LogBook berhasil disimpan!") {
          // Menampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('LogBook berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (responseData['message'] ==
            "Anda sudah mengisi LogBook untuk hari ini!") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda sudah mengisi LogBook untuk hari ini!'),
              backgroundColor: Color.fromARGB(255, 255, 170, 0),
            ),
          );
        } else {
          // Menampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan!';
      if (e is http.ClientException) {
        errorMessage = 'Gagal terhubung ke server!';
      } else if (e is FormatException) {
        errorMessage = 'Format data tidak valid!';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Tambah Log Book',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TextField untuk input tanggal
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Pilih Tanggal',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: Icon(IconlyLight.calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusColor: Colors.blue,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // Warna saat tidak fokus
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 16),
              // TextField Kegiatan
              TextField(
                controller: _activityController,
                decoration: InputDecoration(
                  labelText: 'Kegiatan',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  hintText: 'Jelaskan Kegiatan Anda Hari ini',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // Warna saat tidak fokus
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 16),
              // TextField Kendala
              TextField(
                controller: _problemController,
                decoration: InputDecoration(
                  labelText: 'Kendala',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  hintText: 'Jelaskan kendala yang dihadapi',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                maxLines: 5,
                textCapitalization:
                    TextCapitalization.sentences, // Kapitalisasi kalimat
                keyboardType: TextInputType.text, // Keyboard untuk teks biasa
              ),
              SizedBox(height: 16),
              //button
              Padding(
                padding: EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna latar belakang tombol
                    minimumSize: Size(double.infinity, 50), // Tombol full-width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut membulat
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
