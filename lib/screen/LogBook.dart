import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:aplikasi_absensi/screen/edit_logbook.dart';
import 'package:aplikasi_absensi/screen/input_logbook.dart';

class LogBook extends StatefulWidget {
  const LogBook({super.key});

  @override
  State createState() => _LogBookState();
}

class _LogBookState extends State<LogBook> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Future<List<Map<String, dynamic>>> data1Hari;
  late Future<List<Map<String, dynamic>>> data1Minggu;
  late Future<List<Map<String, dynamic>>> data1Bulan;
  late Future<List<Map<String, dynamic>>> dataSemua;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    data1Hari = fetchData('day');
    data1Minggu = fetchData('week');
    data1Bulan = fetchData('month');
    dataSemua = fetchData('all');
  }

  String getDayName(String tanggal) {
    DateTime dateTime = DateTime.parse(tanggal); // Ubah string ke DateTime
    return DateFormat('EEEE', 'id_ID')
        .format(dateTime); // Format hari dalam bahasa Indonesia
  }

  // Fetch data from API
  Future<List<Map<String, dynamic>>> fetchData(String filter) async {
    final response = await http.get(
      Uri.parse('http://localhost/API_CRUD/log_book.php?filter=$filter'),
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        List data = responseBody['data'];
        return data.map((item) {
          return {
            'id': item['id'],
            'user_id': item['user_id'],
            'tanggal': item['tanggal'],
            'waktu': item['waktu'],
            'kegiatan': item['kegiatan'],
            'kendala': item['kendala'],
            'solusi': item['solusi'],
          };
        }).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget _contentTab(Future<List<Map<String, dynamic>>> data) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 5, // Skeleton loader items
            itemBuilder: (context, index) {
              return Card(
                color: Colors.grey[100],
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              String hari = getDayName(item['tanggal']);
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    navigateToEditPage({
                      "user_id": item['user_id'],
                      "tanggal": item['tanggal'],
                      "waktu": item['waktu'],
                      "kegiatan": item['kegiatan'],
                      "kendala": item['kendala'],
                      "solusi": item['solusi'] ?? "Menunggu Solusi...",
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$hari, ${item['tanggal'] ?? 'No Date'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              item['waktu'] ?? 'No Time',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kegiatan: ${item['kegiatan'] ?? 'No Kegiatan'}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kendala: ${item['kendala'] ?? 'No Kendala'}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solusi: ${item['solusi'] ?? 'Menunggu Solusi...'}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void navigateToEditPage(Map data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDataPage(ListData: data),
      ),
    );
    if (result == true) {
      setState(() {
        data1Hari = fetchData('day');
        data1Minggu = fetchData('week');
        data1Bulan = fetchData('month');
        dataSemua = fetchData('all');
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
          'Log Book',
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
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LogBook',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Isi LogBook Anda Hari Ini',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InputLogbook(),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          data1Hari = fetchData('day');
                          data1Minggu = fetchData('week');
                          data1Bulan = fetchData('month');
                          dataSemua = fetchData('all');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Tambah LogBook',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'History LogBook',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: tabController,
                      isScrollable: false,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      tabs: const [
                        Tab(text: '1 Hari'),
                        Tab(text: '1 Minggu'),
                        Tab(text: '1 Bulan'),
                        Tab(text: 'Semua'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _contentTab(data1Hari),
                  _contentTab(data1Minggu),
                  _contentTab(data1Bulan),
                  _contentTab(dataSemua),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
