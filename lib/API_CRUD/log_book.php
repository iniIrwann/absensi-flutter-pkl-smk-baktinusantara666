<?php
header("Content-Type: application/json");
require "db_utama.php";

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $today = date('Y-m-d');
    $currentDate = new DateTime($today);

    // Menentukan hari Senin minggu ini
    $currentDate->modify('monday this week');
    $startWeek = $currentDate->format('Y-m-d');

    // Menentukan tanggal 1 bulan ini
    $startMonth = $currentDate->modify('first day of this month')->format('Y-m-d');

    // Menentukan tanggal terakhir bulan ini
    $endMonth = $currentDate->modify('last day of this month')->format('Y-m-d');

    // Periksa apakah filter diterapkan
    if (isset($_GET['filter'])) {
        $filter = $_GET['filter'];

        if ($filter == 'day') {
            $stmt = $conn->prepare("SELECT * FROM log_book WHERE tanggal = ? ORDER BY tanggal DESC");
            $stmt->bind_param("s", $today);
        } elseif ($filter == 'week') {
            $endWeek = (new DateTime($startWeek))->modify('+7 days')->format('Y-m-d');
            $stmt = $conn->prepare("SELECT * FROM log_book WHERE tanggal BETWEEN ? AND ? ORDER BY tanggal DESC");
            $stmt->bind_param("ss", $startWeek, $endWeek);
        } elseif ($filter == 'month') {
            $stmt = $conn->prepare("SELECT * FROM log_book WHERE tanggal BETWEEN ? AND ? ORDER BY tanggal DESC");
            $stmt->bind_param("ss", $startMonth, $endMonth);
        } elseif ($filter == 'all') {
            $stmt = $conn->prepare("SELECT * FROM log_book ORDER BY tanggal DESC");
        } else {
            echo json_encode(["status" => "error", "message" => "Filter tidak valid"]);
            exit;
        }

        $stmt->execute();
        $result = $stmt->get_result();

        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = [
                "id" => $row["id"],
                "user_id" => $row["user_id"],
                "tanggal" => $row["tanggal"],
                "waktu" => $row["waktu"],
                "kegiatan" => $row["kegiatan"],
                "kendala" => $row["kendala"],
                "solusi" => $row["solusi"]
            ];
        }

        if (!empty($data)) {
            echo json_encode(["status" => "success", "data" => $data]);
        } else {
            echo json_encode(["status" => "empty", "message" => "Tidak ada kegiatan dalam periode ini"]);
        }

        $stmt->close();
    }
}

$conn->close();
?>