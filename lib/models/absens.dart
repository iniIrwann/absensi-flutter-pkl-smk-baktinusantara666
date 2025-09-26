class Absensi {
  final String userId;
  final String jamMasuk;
  final String jamKeluar;

  Absensi({
    required this.userId,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  // Factory constructor untuk membuat objek Absensi dari JSON
  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      userId: json['user_id'].toString(),
      jamMasuk: json['jam_masuk']?? "00:00:00",
      jamKeluar: json['jam_keluar'] ?? "00:00:00",
    );
  }
}
