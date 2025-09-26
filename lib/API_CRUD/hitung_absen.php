<?php
header("Content-Type: application/json");
require "db_utama.php"; // Koneksi ke database

// Pastikan user_id dikirim sebagai parameter GET
if (!isset($_GET['user_id'])) {
    echo json_encode(["error" => "Parameter user_id diperlukan"]);
    exit;
}

$user_id = intval($_GET['user_id']); // Hindari SQL Injection

// Ambil bulan dan tahun saat ini
$bulan = date("m");
$tahun = date("Y");

// Array nama bulan dalam bahasa Indonesia
$nama_bulan = [
    "01" => "Januari", "02" => "Februari", "03" => "Maret", "04" => "April",
    "05" => "Mei", "06" => "Juni", "07" => "Juli", "08" => "Agustus",
    "09" => "September", "10" => "Oktober", "11" => "November", "12" => "Desember"
];

// Konversi angka bulan ke nama bulan
$bulan_text = $nama_bulan[$bulan];

// Query untuk menghitung jumlah masing-masing status berdasarkan bulan dan tahun saat ini
$query = "
    SELECT 
        SUM(CASE WHEN status = 'Hadir' THEN 1 ELSE 0 END) AS hadir,
        SUM(CASE WHEN status = 'Sakit' THEN 1 ELSE 0 END) AS sakit,
        SUM(CASE WHEN status = 'Izin' THEN 1 ELSE 0 END) AS izin,
        SUM(CASE WHEN status = 'Alpa' THEN 1 ELSE 0 END) AS alpa
    FROM absensi
    WHERE user_id = ? AND MONTH(tanggal) = ? AND YEAR(tanggal) = ?
";

$stmt = $conn->prepare($query);
$stmt->bind_param("iii", $user_id, $bulan, $tahun);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();

// Jika data ditemukan
if ($data) {
    echo json_encode([
        "bulan" => $bulan_text, // Gunakan nama bulan
        "tahun" => $tahun,
        "hadir" => $data['hadir'],
        "sakit" => $data['sakit'],
        "izin" => $data['izin'],
        "alpa" => $data['alpa']
    ]);
} else {
    echo json_encode(["error" => "Data tidak ditemukan"]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
