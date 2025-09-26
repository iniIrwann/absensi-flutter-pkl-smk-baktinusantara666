<?php
include 'db_utama.php';
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode(['status' => 'error', 'message' => 'Hanya metode POST yang diperbolehkan!']);
    exit;
}

// Ambil data dari request
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$date = isset($_POST['date']) ? trim($_POST['date']) : "";
$activity = isset($_POST['activity']) ? trim($_POST['activity']) : "";
$problem = isset($_POST['problem']) ? trim($_POST['problem']) : "";

if (!$user_id || empty($date) || empty($activity) || empty($problem)) {
    echo json_encode(['status' => 'error', 'message' => 'Semua data harus diisi!']);
    exit;
}

// Pastikan format tanggal benar
$formattedDate = date('Y-m-d', strtotime($date));

// Cek apakah logbook sudah ada untuk tanggal ini
$sql = "SELECT id FROM log_book WHERE tanggal = ? AND user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $formattedDate, $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Anda sudah mengisi LogBook untuk hari ini!']);
} else {
    // Simpan data baru
    $sql = "INSERT INTO log_book (user_id, tanggal, waktu, kegiatan, kendala) VALUES (?, ?, NOW(), ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("isss", $user_id, $formattedDate, $activity, $problem);
    
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'LogBook berhasil disimpan!']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Gagal menyimpan LogBook!']);
    }
}

$stmt->close();
$conn->close();
?>
