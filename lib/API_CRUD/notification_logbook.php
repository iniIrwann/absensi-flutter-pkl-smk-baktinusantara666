<?php
include "db_utama.php";

header("Content-Type: application/json");

if (!isset($_GET['userId'])) {
    echo json_encode(["status" => "error", "message" => "Parameter userId diperlukan"]);
    exit;
}

$user_id = intval($_GET['userId']);

$sql = "SELECT id, user_id, tanggal, waktu, kegiatan, 
               COALESCE(kendala, '') AS kendala, 
               COALESCE(solusi, '') AS solusi, 
               status_notif 
        FROM log_book 
        WHERE user_id = ? AND solusi IS NOT NULL AND solusi <> 'Menunggu Solusi...'
        ORDER BY status_notif ASC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if (!$result) {
    die(json_encode(["status" => "error", "message" => "Query gagal: " . $conn->error]));
}

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = [
        "id" => $row["id"],
        "user_id" => $row["user_id"],
        "message" => "Admin telah memberikan solusi untuk logbook: " . $row["kegiatan"],
        "kendala" => $row["kendala"],
        "tanggal" => $row["tanggal"],
        "solusi" => $row["solusi"],
        "status_notif" => $row["status_notif"],
        "read" => false
    ];
}

echo json_encode(["status" => "success", "notifications" => $notifications]);

$stmt->close();
$conn->close();
?>
