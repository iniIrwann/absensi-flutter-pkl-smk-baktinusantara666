<?php
include 'db_utama.php';

header('Content-Type: application/json');

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Pastikan userID dikirim dalam request GET
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET["userId"])) {
    $userID = $_GET["userId"];

    // Gunakan prepared statement untuk mencegah SQL Injection
    $stmt = $conn->prepare("SELECT * FROM pegawai WHERE id = ?");
    $stmt->bind_param("i", $userID);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $users = array();

    while ($row = $result->fetch_assoc()) {
        // Pastikan 'profile_picture' ada dan tidak kosong
        if (!empty($row['profile_picture']) && !filter_var($row['profile_picture'], FILTER_VALIDATE_URL)) {
            $row['image'] = 'http://192.168.152.19/API_CRUD/uploads_utama/' . $row['profile_picture'];
        } else {
            $row['image'] = $row['profile_picture'] ?? null; // Gunakan `null` jika tidak ada gambar
        }

        $users[] = $row;
    }

    // Jika user tidak ditemukan
    if (empty($users)) {
        echo json_encode(["error" => "User not found"]);
    } else {
        echo json_encode($users);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request"]);
}

$conn->close();
?>
