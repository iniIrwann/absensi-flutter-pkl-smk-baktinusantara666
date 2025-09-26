<?php
header("Content-Type: application/json");
require "db_utama.php"; 

if (!isset($_GET['user_id'])) {
    echo json_encode(["error" => "Parameter user_id diperlukan"]);
    exit;
}

$user_id = intval($_GET['user_id']); 
$today = date('Y-m-d');
$query = "SELECT id, user_id, tanggal, lokasi_kerja, latitude, longitude, status, keterangan, jam_masuk, jam_keluar 
          FROM absensi WHERE user_id = ? AND tanggal = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("is", $user_id, $today);
$stmt->execute();
$result = $stmt->get_result();

$data = $result->fetch_all(MYSQLI_ASSOC); 

if (!empty($data)) {
    echo json_encode(["success" => true, "data" => $data]);
} else {
    echo json_encode(["success" => false, "message" => "Data tidak ditemukan"]);
}

$stmt->close();
$conn->close();
?>
