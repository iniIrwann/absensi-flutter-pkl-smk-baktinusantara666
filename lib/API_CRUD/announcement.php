<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

include 'db_utama.php';

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT id, tanggal, title, isi_pengumuman, pdf_url FROM announcements ORDER BY tanggal ASC LIMIT 5";
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        $announcements = [];
        while ($row = $result->fetch_assoc()) {
            // Pastikan 'pdf_url' ada dan tidak kosong
            if (!empty($row['pdf_url']) && !filter_var($row['pdf_url'], FILTER_VALIDATE_URL)) {
                $row['pdf_url'] = 'http://192.168.152.19/API_CRUD/pdf/' . $row['pdf_url'];
            } else {
                $row['pdf_url'] = $row['pdf_url'] ?? null; 
            }
        
            $announcements[] = $row;
        }
        echo json_encode($announcements);
    } else {
        echo json_encode(["message" => "No announcements found"]);
    }
}

$conn->close();