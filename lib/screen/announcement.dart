import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Announcement extends StatefulWidget {
  final Map ListData;

  const Announcement({super.key, required this.ListData});

  @override
  State<Announcement> createState() => AnnouncementState();
}

class AnnouncementState extends State<Announcement> {
  void _downloadPDF(String url) async {
    final Uri uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (kDebugMode) {
        debugPrint("Tidak dapat membuka URL: $url");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Detail Pengumuman',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200],
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
                if (widget.ListData['pdf_url'] != null &&
                    widget.ListData['pdf_url'].isNotEmpty)
                  TextButton(
                    onPressed: () => _downloadPDF(widget.ListData['pdf_url']),
                    child:
                        Text('Lihat PDF', style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.ListData['isi_pengumuman'] ?? 'Tidak ada isi pengumuman',
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
