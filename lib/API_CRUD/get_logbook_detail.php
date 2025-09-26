<?php
header("Content-Type: application/json");
require "db_utama.php"; // File konfigurasi database

// Cek apakah ID logbook dikirimkan dan valid
if (!isset($_GET['logbookId']) || empty($_GET['logbookId']) || !filter_var($_GET['logbookId'], FILTER_VALIDATE_INT)) {
    echo json_encode(["status" => "error", "message" => "logbookId tidak valid"]);
    exit;
}

$logbookId = intval($_GET['logbookId']);

// Query untuk mengambil detail logbook
$query = "SELECT * FROM log_book WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $logbookId);
$stmt->execute();
$result = $stmt->get_result();

// Cek apakah data ditemukan
if ($result->num_rows > 0) {
    $logbook = $result->fetch_assoc();
    echo json_encode(["status" => "success", "logbook" => $logbook], JSON_UNESCAPED_UNICODE);
} else {
    http_response_code(404); // Berikan kode error HTTP 404
    echo json_encode(["status" => "error", "message" => "Logbook tidak ditemukan"]);
}

$stmt->close();
$conn->close();