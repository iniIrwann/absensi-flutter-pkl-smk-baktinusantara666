<?php
header('Content-Type: application/json');
include 'db_utama.php';

// Fungsi untuk mengirimkan response JSON
function sendResponse($status, $data) {
    echo json_encode([
        "status" => $status,
        "data" => $data
    ]);
}

// Menangani permintaan
if (isset($_GET['tanggal'])) {
    $tanggal = $_GET['tanggal'];

    // Jika parameter 'incoming_schedule' ada, berarti meminta jadwal mendatang
    if (isset($_GET['incoming_schedule']) && $_GET['incoming_schedule'] == 'true') {
        $sql = "SELECT * FROM kalender WHERE tanggal > '$tanggal' ORDER BY tanggal ASC";
    } else {
        // Menampilkan kegiatan berdasarkan tanggal yang dipilih
        $sql = "SELECT * FROM kalender WHERE tanggal = '$tanggal'";
    }

    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $kegiatan = [];
        while ($row = $result->fetch_assoc()) {
            $kegiatan[] = [
                "tanggal" => $row['tanggal'],
                "judul_kegiatan" => $row['judul_kegiatan'],
                "isi_kegiatan" => $row['isi_kegiatan']
            ];
        }
        sendResponse('success', $kegiatan);
    } else {
        sendResponse('error', []);
    }
} else {
    sendResponse('error', []);
}

// Menutup koneksi database
$conn->close();
?>
