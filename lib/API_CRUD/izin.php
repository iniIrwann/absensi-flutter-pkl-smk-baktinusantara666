<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_utama.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data['user_id'], $data['status'], $data['date'], $data['keterangan'], $data['jenisIzin'])) {
        $user_id = $data['user_id'];
        $status = $data['status'];
        $tanggal = $data['date']; // Menggunakan tanggal yang dikirim dari Flutter
        $keterangan = $data['keterangan'];
        $jenisIzin = $data['jenisIzin'];

        // Cek apakah sudah ada absensi pada hari tersebut
        $stmt = $conn->prepare("SELECT * FROM absensi WHERE user_id = ? AND tanggal = ?");
        $stmt->bind_param("ss", $user_id, $tanggal);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Jika sudah ada absensi, tidak bisa mengubah ke izin
            echo json_encode(["message" => "Anda sudah melakukan absen pada tanggal ini, tidak bisa mengubah ke izin."]);
        } else {
            // Menyimpan data izin
            $stmt = $conn->prepare("INSERT INTO absensi (user_id, tanggal, lokasi_kerja, status, keterangan, latitude, longitude, jam_masuk, jam_keluar) 
                                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $lokasi_kerja = "-";  
            $latitude = "-";  
            $longitude = "-";
            $jammasuk = "00:00:00";
            $jamkeluar = "00:00:00";
            $stmt->bind_param("sssssssss", $user_id, $tanggal, $lokasi_kerja, $jenisIzin, $keterangan, $latitude, $longitude, $jammasuk,$jamkeluar);

            if ($stmt->execute()) {
                echo json_encode(["message" => "Izin berhasil disimpan!"]);
            } else {
                echo json_encode(["message" => "Gagal menyimpan data izin."]);
            }
        }

        $stmt->close();
    } else {
        echo json_encode(["message" => "Data tidak lengkap"]);
    }
}

$conn->close();
?>
