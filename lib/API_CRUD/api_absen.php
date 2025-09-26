<?php
include 'db_utama.php';

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Mengambil data absensi hanya pada hari ini (tanggal saat ini)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Ambil tanggal hari ini
    $tanggal_hari_ini = date('Y-m-d');
    
    // Query untuk mengambil data absensi hanya pada hari ini
    $stmt = $conn->prepare("SELECT user_id, tanggal, jam_masuk, jam_keluar FROM absensi WHERE tanggal = ? LIMIT 1");
    $stmt->bind_param("s", $tanggal_hari_ini);
    $stmt->execute();
    $result = $stmt->get_result();

    $absensi = array();

    while ($row = $result->fetch_assoc()) {
        $absensi[] = $row;
    }

    if (count($absensi) > 0) {
        echo json_encode($absensi);
    } else {
        echo json_encode(["message" => "Tidak ada data absensi untuk hari ini."]);
    }

    $stmt->close();
}

$conn->close();
?>
