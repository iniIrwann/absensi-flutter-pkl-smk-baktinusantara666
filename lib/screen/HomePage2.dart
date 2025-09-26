import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_absensi/screen/KalenderPage.dart';
import 'package:aplikasi_absensi/screen/LogBook.dart';
import 'package:aplikasi_absensi/screen/announcement.dart';
import 'package:aplikasi_absensi/screen/fiturutama2.dart';
import 'package:aplikasi_absensi/screen/izin.dart';
import 'package:aplikasi_absensi/screen/logKehadiran.dart';
import 'package:aplikasi_absensi/screen/notification_screen.dart';
import 'package:aplikasi_absensi/screen/notifications.dart';
import 'package:aplikasi_absensi/service/api_service.dart';
import 'package:aplikasi_absensi/models/absens.dart';
import 'package:aplikasi_absensi/models/users.dart';

class Homepage2 extends StatefulWidget {
  const Homepage2({super.key});

  @override
  State<Homepage2> createState() => _Homepage2State();
}

class _Homepage2State extends State<Homepage2> {
  String formattedDate =
      DateFormat('EEEE dd MMM yyyy', 'id_ID').format(DateTime.now());
  late Future<User> _usersFuture;
  late Future<Map<String, DateTime?>> _jamMasukDanKeluarFuture;
  late Future<Absensi?> _absenFuture;
  late Future<List<Map<String, dynamic>>> _annoncementFuture;

  String getGreeting() {
    int hour = DateTime.now().hour;

    if (hour >= 6 && hour < 11) {
      return "Good Morning";
    } else if (hour >= 11 && hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Night";
    }
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = Future.error("User not loaded");
    _absenFuture = Future.value(null);
    _annoncementFuture = Future.value([]);
    _jamMasukDanKeluarFuture = Future.value({});
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '0');

    if (userId != null) {
      setState(() {
        _usersFuture = ApiService().fetchUser(userId);
        _absenFuture = ApiService().fetchAbsensi(userId);
        _annoncementFuture = ApiService().fetchAnnouncements();
        _jamMasukDanKeluarFuture = ApiService().fetchJamMasukDanKeluar(userId);
      });
    }
  }

  void _reloadData() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ClockIn()),
    );
    if (result == true) {
      setState(() {
        _loadUserData();
      });
    }
  }

  Widget buildFeatures({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                imagePath,
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildSectionAbsen(
      BuildContext context, DateTime? jamMasuk, DateTime? jamKeluar) {
    String title;
    String buttonText;
    String imagePath;
    int hour = DateTime.now().hour;

    if (jamMasuk == null) {
      title = 'Kamu Belum Absen!';
      buttonText = 'Clock In Now';
      imagePath = 'assets/images/ClockIn-HomePage.png';
    } else if (jamKeluar == null && hour <= 12) {
      title = 'Kerja Dulu, Semangat!';
      buttonText = '';
      imagePath = 'assets/images/KerjaDulu-HomePage.png';
    } else if (jamKeluar == null && hour >= 12) {
      title = 'Waktunya Clock Out!';
      buttonText = 'Clock Out Now';
      imagePath = 'assets/images/ClockOut-HomePage.png';
    } else {
      title = 'Absensi selesai \nTerima kasih!';
      buttonText = '';
      imagePath = 'assets/images/ClockOut-HomePage.png';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(width: 2, color: Colors.blue),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 150,
            height: 110,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 33, 33, 33),
                  ),
                ),
                if (buttonText.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: _reloadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  Widget buildSectionAbsenSkeleton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 25,
                  width: 125,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
      String title, String content, String date, String pdf) {
    return InkWell(
      onTap: () {
        _navigateToAnnouncement({
          "tanggal": date,
          "title": title,
          "isi_pengumuman": content,
          "pdf_url": pdf,
        });
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  (pdf.isNotEmpty && pdf != "NoPdf")
                      ? "1 Lampiran"
                      : "0 Lampiran",
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAnnouncement(Map data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Announcement(ListData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);

    String greeting = getGreeting();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF0051FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.only(
                  bottom: 20, left: 16, right: 16, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                        future: _usersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 15,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            );
                          }
                          // if (snapshot.connectionState ==
                          //     ConnectionState.waiting) {
                          //   return Center(
                          //     child: CircularProgressIndicator(
                          //       valueColor:
                          //           AlwaysStoppedAnimation(Colors.white),
                          //     ),
                          //   );
                          // }
                          else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData) {
                            return Center(child: Text("No user found"));
                          } else {
                            User user = snapshot.data!;
                            print('Url Gambar: ${user.imageUrl}');
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        NetworkImage(user.imageUrl),
                                    onBackgroundImageError: (_, __) =>
                                        Icon(Icons.error),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$greeting, ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${user.firstname}!',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        user.jabatan,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen()),
                          );
                          // if (notificationService.unreadCount > 0) {
                          //   notificationService
                          //       .markAsRead(15); // Kirim ID jurnal tertentu
                          // }
                        },
                        child: Stack(
                          children: [
                            Icon(Icons.notifications,
                                color: Colors.white, size: 25),
                            if (notificationService.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    '${notificationService.unreadCount}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  //LOG TIME
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF007DD6),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                IconlyLight.calendar,
                                // size: 30,
                                color: Colors.white,
                              ),
                              // Icon(Icons.calendar_month_rounded,
                              //     size: 33, color: Colors.white),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hari ini - $formattedDate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Shift Regular Office (08.00-15.00)',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder(
                          future: _absenFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildClockInOutColumnSkeleton(),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumnSkeleton(),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumnSkeleton(),
                                ],
                              );
                            }
                            // if (snapshot.connectionState ==
                            //     ConnectionState.waiting) {
                            //   return Center(child: CircularProgressIndicator());
                            // }
                            else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildClockInOutColumn("Clock In", "--:--",
                                      Color(0xFFBAFFC5), Colors.green),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumn("Total Jam", "--:--",
                                      Color(0xFFBCBCBC), Colors.grey[700]!),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumn("Clock Out", "--:--",
                                      Color(0xFFFFBFA6), Colors.red),
                                ],
                              );
                            } else {
                              Absensi absensi = snapshot.data!;
                              String jamMasukFormatted =
                                  _formatTime(absensi.jamMasuk);
                              String jamPulangFormatted =
                                  _formatTime(absensi.jamKeluar);
                              String totalJamFormatted = _calculateTotalJam(
                                  absensi.jamMasuk, absensi.jamKeluar);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildClockInOutColumn(
                                      "Clock In",
                                      jamMasukFormatted,
                                      Color(0xFFBAFFC5),
                                      Colors.green),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumn(
                                      "Total Jam",
                                      totalJamFormatted,
                                      Color(0xFFBCBCBC),
                                      Colors.grey[700]!),
                                  Container(
                                      height: 40, width: 1, color: Colors.grey),
                                  _buildClockInOutColumn(
                                      "Clock Out",
                                      jamPulangFormatted,
                                      Color(0xFFFFBFA6),
                                      Colors.red),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Attendance Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, DateTime?>>(
                future: _jamMasukDanKeluarFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildSectionAbsenSkeleton();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No data available'));
                  } else {
                    DateTime? jamMasuk = snapshot.data?['jam_masuk'];
                    DateTime? jamKeluar = snapshot.data?['jam_keluar'];
                    return buildSectionAbsen(context, jamMasuk, jamKeluar);
                  }
                },
              ),
            ),

            // Features Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Features :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Features List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildFeatures(
                      imagePath: 'assets/images/attedance.png',
                      label: 'Kehadiran',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogKehadiran()),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    buildFeatures(
                      imagePath: 'assets/images/letter.png',
                      label: 'Izin',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StatusButtons()),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    buildFeatures(
                      imagePath: 'assets/images/schedule.png',
                      label: 'Kalender',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const KalenderPage()),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    buildFeatures(
                      imagePath: 'assets/images/notepad.png',
                      label: 'Log Book',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogBook()),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    buildFeatures(
                      imagePath: 'assets/images/salary.png',
                      label: 'Slip Gaji',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Announcements Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Announcement:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _annoncementFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  );
                  // return ListView.builder(
                  //   itemCount: 3, // Skeleton loader items
                  //   itemBuilder: (context, index) {
                  //     return Card(
                  //       margin: const EdgeInsets.symmetric(vertical: 8),
                  //       elevation: 2,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(16),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Container(
                  //                   height: 12,
                  //                   width: 75,
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.grey[300],
                  //                     borderRadius: BorderRadius.circular(4),
                  //                   ),
                  //                 ),
                  //                 Container(
                  //                   height: 12,
                  //                   width: 75,
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.grey[300],
                  //                     borderRadius: BorderRadius.circular(4),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Column(
                  //               children: [
                  //                 Container(
                  //                   height: 12,
                  //                   width: 100,
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.grey[300],
                  //                     borderRadius: BorderRadius.circular(4),
                  //                   ),
                  //                 ),
                  //                 Container(
                  //                   height: 12,
                  //                   width: 100,
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.grey[300],
                  //                     borderRadius: BorderRadius.circular(4),
                  //                   ),
                  //                 ),
                  //                 Container(
                  //                   height: 12,
                  //                   width: 100,
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.grey[300],
                  //                     borderRadius: BorderRadius.circular(4),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             const SizedBox(height: 8),
                  //             Container(
                  //               height: 10,
                  //               width: 200,
                  //               decoration: BoxDecoration(
                  //                 color: Colors.grey[300],
                  //                 borderRadius: BorderRadius.circular(4),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada pengumuman'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      children: snapshot.data!.map((item) {
                        return _buildAnnouncementCard(
                          item['title'] ?? 'Tanpa Judul',
                          item['isi_pengumuman'] ?? 'Tidak ada isi pengumuman',
                          item['tanggal'] ?? 'Tanggal tidak tersedia',
                          item['pdf_url'] ?? '',
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockInOutColumn(
      String label, String time, Color bgColor, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildClockInOutColumnSkeleton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          height: 20,
          width: 65,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[200],
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   // child: Container(
        //   //   height: 10,
        //   //   width: 50,
        //   //   decoration: BoxDecoration(
        //   //     color: Colors.grey[300],
        //   //     borderRadius: BorderRadius.circular(4),
        //   //   ),
        //   // ),
        // ),
        const SizedBox(height: 5),
        Container(
          height: 12,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (e) {
      return "--:--";
    }
  }

  String _calculateTotalJam(String jamMasuk, String jamPulang) {
    if (jamPulang == "00:00:00" || jamMasuk == "00:00:00") return "--:--";
    DateTime jamMasukTime = DateFormat('HH:mm:ss').parse(jamMasuk);
    DateTime jamPulangTime = DateFormat('HH:mm:ss').parse(jamPulang);
    Duration totalJam = jamPulangTime.difference(jamMasukTime);
    int jam = totalJam.inHours;
    int menit = totalJam.inMinutes % 60;
    return "${jam}H ${menit.toString().padLeft(2, '0')}M";
  }
}
