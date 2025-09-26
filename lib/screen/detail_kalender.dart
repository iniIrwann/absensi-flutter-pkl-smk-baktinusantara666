import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailKalender extends StatefulWidget {
  final Map ListData; // Add this line to accept data

  const DetailKalender({super.key, required this.ListData}); // Constructor

  @override
  State<DetailKalender> createState() => DetailKalenderState();
}

class DetailKalenderState extends State<DetailKalender> {
  void _downloadPDF(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka PDF')),
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
          'Detail Kalender Event',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.ListData['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    overflow:
                        TextOverflow.ellipsis, // Tambahkan jika teks panjang
                  ),
                ),
                if (widget.ListData['pdf_url'] != null && widget.ListData['pdf_url'].isNotEmpty)
                          TextButton(
                            onPressed: () => _downloadPDF(widget.ListData['pdf_url']),
                            child: Text('Lihat PDF', style: TextStyle(color: Colors.blue)),
                          ),
            
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.ListData['description'] ?? 'Tidak ada isi pengumuman',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${widget.ListData['tanggal'] ?? 'Tidak tersedia'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
