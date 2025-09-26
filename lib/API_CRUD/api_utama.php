<?php
include 'db_utama.php';

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Mengambil data pengguna jika request adalah GET
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $result = $conn->query("SELECT * FROM pegawai");
    $users = array();

    while ($row = $result->fetch_assoc()) {
        // Pastikan hanya menambahkan base URL jika path gambar tidak sudah berupa URL penuh
        if (!str_contains($row['profile_picture'], 'http://')) {
            $row['image'] = 'http://192.168.152.19/API_CRUD/uploads_utama/' . $row['profile_picture'];
        } else {
            $row['image'] = $row['profile_picture'];
        }
        $users[] = $row;
    }

    echo json_encode($users);
}

$conn->close();
?>
