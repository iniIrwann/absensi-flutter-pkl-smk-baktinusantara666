<?php
include 'db_utama.php';

$user_id = isset($_GET['userId']) ? intval($_GET['userId']) : 0;

$stmt = $conn->prepare("SELECT COUNT(*) AS jumlah FROM log_book 
WHERE user_id = ? 
AND status_notif = 'baru' 
AND solusi IS NOT NULL 
AND solusi <> 'Menunggu Solusi...'");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result) {
    $row = $result->fetch_assoc();
    $jumlah = isset($row['jumlah']) ? (int) $row['jumlah'] : 0;
    echo json_encode(["status" => "success", "jumlah" => $jumlah]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mengambil data"]);
}

$stmt->close();
$conn->close();
