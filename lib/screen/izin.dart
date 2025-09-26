import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StatusButtons extends StatefulWidget {
  const StatusButtons({super.key});

  @override
  _StatusButtonsState createState() => _StatusButtonsState();
}

class _StatusButtonsState extends State<StatusButtons> {
  // Menyimpan status yang dipilih
  String selectedStatus = '';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final List<String> statuses = ['Izin', 'Sakit', 'Keperluan lain', 'Lainnya'];

  @override
  void dispose() {
    _dateController.dispose();
    _keteranganController.dispose();
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
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  Future<void> _submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');
    final date = _dateController.text;
    final keterangan = _keteranganController.text;
    if (date.isEmpty || keterangan.isEmpty || selectedStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua inputan harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final url =
          Uri.parse('http://localhost/API_CRUD/izin.php'); // Sesuaikan URL API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'date': date,
          'keterangan': keterangan,
          'jenisIzin': selectedStatus,
          'status': "Izin",
        }),
      );
      // debugPrint('Response body: ${response.body}');

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor:
                responseData['message'] == "Izin berhasil disimpan!"
                    ? Colors.green
                    : Colors.red,
          ),
        );
        if (responseData['message'] == "Izin berhasil disimpan!") {
          Navigator.pop(context, true); // Menutup halaman setelah sukses
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Opsi Izin',
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
        // Scrollable body
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Izin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Disable GridView scrolling
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3,
              children:
                  statuses.map((status) => _buildStatusButton(status)).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Tanggal Izin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
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
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () {
                _selectDate(context);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Keterangan izin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keteranganController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                hintText: 'Masukan keterangan izin anda',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    bool isSelected = selectedStatus == status;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 1,
        ),
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
