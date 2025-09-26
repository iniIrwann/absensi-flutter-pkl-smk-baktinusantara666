<?php
header("Content-Type: application/json");
require "db_utama.php"; // Panggil koneksi database

// Pastikan user_id dikirim sebagai parameter GET
if (!isset($_GET['user_id'])) {
    echo json_encode(["error" => "Parameter user_id diperlukan"]);
    exit;
}

$user_id = intval($_GET['user_id']); // Hindari SQL Injection

$tanggal = date('Y-m-d'); // Mengambil tanggal hari ini

// Query untuk mencari absensi pada hari ini
$stmt = $conn->prepare("SELECT * FROM absensi WHERE user_id = ? AND tanggal = ? AND status = 'Hadir' ORDER BY id DESC LIMIT 1");
$stmt->bind_param("is", $user_id, $tanggal); // Bind parameter yang benar
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Ambil data absensi terakhir
    $data = $result->fetch_assoc();
    echo json_encode([
        "jam_masuk" => $data['jam_masuk'] ?: null,
        "jam_keluar" => $data['jam_keluar'] ?: null
    ]);
} else {
    echo json_encode(["error" => "Belum ada absensi untuk hari ini"]);
}

// Menutup koneksi
$stmt->close();
$conn->close();
?>
