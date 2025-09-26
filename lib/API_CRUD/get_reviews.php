<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_utama.php';

if ($conn->connect_error) {
    die(json_encode(["error" => "Koneksi database gagal"]));
}

$sql = "SELECT * FROM announcements ORDER BY tanggal DESC";
$result = $conn->query($sql);

$announcements = [];
while ($row = $result->fetch_assoc()) {
    // Pastikan 'pdf_url' ada dan tidak kosong
    if (!empty($row['pdf_url']) && !filter_var($row['pdf_url'], FILTER_VALIDATE_URL)) {
        $row['pdf_url'] = 'http://192.168.152.19/API_CRUD/pdf/' . $row['pdf_url'];
    } else {
        $row['pdf_url'] = $row['pdf_url'] ?? null; // Gunakan `null` jika tidak ada url
    }

    $announcements[] = $row;
}

echo json_encode($announcements);
$conn->close();
?>
