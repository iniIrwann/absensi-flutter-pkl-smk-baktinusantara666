<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

include 'db_utama.php';

// Aktifkan error reporting untuk debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data['user_id'], $data['latitude'], $data['longitude'], $data['status'], $data['wfh'])) {
        $user_id = $data['user_id'];
        $wfh = $data['wfh'];
        $latitude = $data['latitude'];
        $longitude = $data['longitude'];
        $status = $data['status'];
        $tanggal = date('Y-m-d'); // Mengambil tanggal hari ini
        $waktu = date('H:i:s'); // Waktu saat ini

        // Debug log input data
        error_log("Input Data: " . json_encode($data));

        // Cek apakah sudah ada absen pada hari ini
        $stmt = $conn->prepare("SELECT * FROM absensi WHERE user_id = ? AND tanggal = ?");
        if (!$stmt) {
            echo json_encode(["message" => "Query Error: " . $conn->error]);
            exit;
        }
        $stmt->bind_param("ss", $user_id, $tanggal);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Ambil data absensi yang sudah ada
            $absen = $result->fetch_assoc();
            if (in_array($absen["status"], ['Izin', 'Sakit', 'Keperluan lain', 'Lainnya'])) {
                echo json_encode(["message" => "Hari ini Anda " . $absen['status'] .", tidak dapat melakukan absensi masuk."]);
                exit;
            }

            // Cek apakah logbook sudah diisi
            $logbookStmt = $conn->prepare("SELECT * FROM log_book WHERE user_id = ? AND tanggal = ?");
            if (!$logbookStmt) {
                echo json_encode(["message" => "Query Error: " . $conn->error]);
                exit;
            }
            $logbookStmt->bind_param("ss", $user_id, $tanggal);
            $logbookStmt->execute();
            $logbookResult = $logbookStmt->get_result();

            if ($logbookResult->num_rows == 0) {
                echo json_encode(["message" => "Anda harus mengisi logbook terlebih dahulu sebelum clock out."]);
            } else {
                if ($absen['status'] == 'Hadir' && $absen['jam_keluar'] == NULL && $status == 'Keluar') {
                    $stmt = $conn->prepare("UPDATE absensi SET jam_keluar = NOW() WHERE id = ?");
                    $stmt->bind_param("i", $absen['id']);
                    if ($stmt->execute()) {
                        echo json_encode(["message" => "Absen keluar berhasil!"]);
                    } else {
                        echo json_encode(["message" => "Gagal menyimpan jam keluar: " . $stmt->error]);
                    }
                } elseif ($absen['status'] == 'Hadir' && $status == 'Hadir') {
                    echo json_encode(["message" => "Anda sudah clock in"]);
                } elseif ($absen['status'] == 'Hadir' && $status == 'Keluar') {
                    echo json_encode(["message" => "Anda sudah clock out, absensi selesai."]);
                }
            }
            $logbookStmt->close();
        } else {
            if ($status == 'Hadir') {
                // **PERBAIKAN QUERY INSERT**
                $stmt = $conn->prepare("INSERT INTO absensi (user_id, tanggal, lokasi_kerja, latitude, longitude, status, jam_masuk) 
                                        VALUES (?, ?, ?, ?, ?, ?, NOW())");
                if (!$stmt) {
                    echo json_encode(["message" => "Query Error: " . $conn->error]);
                    exit;
                }
                $stmt->bind_param("ssssss", $user_id, $tanggal, $wfh, $latitude, $longitude, $status);
                if ($stmt->execute()) {
                    echo json_encode(["message" => "Absen masuk berhasil!"]);
                } else {
                    echo json_encode(["message" => "Gagal menyimpan absen masuk: " . $stmt->error]);
                }
            } elseif ($status == 'Keluar') {
                echo json_encode(["message" => "Anda harus melakukan absen masuk terlebih dahulu sebelum clock out."]);
            } else {
                echo json_encode(["message" => "Status absensi tidak valid."]);
            }
        }
        $stmt->close();
    } else {
        echo json_encode(["message" => "Data tidak lengkap"]);
    }
} else {
    echo json_encode(["message" => "Metode permintaan tidak valid"]);
}

$conn->close();
?>
