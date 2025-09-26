<?php
include 'db_utama.php';

header('Content-Type: application/json'); // Pastikan respons dalam format JSON

// Ambil input secara aman
$username = trim($_POST["username"]);
$password = trim($_POST["password"]); 

$stmt = $conn->prepare("SELECT * FROM pegawai WHERE email = ? AND password = ?");
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user) {
        $response = [
            "status" => "Success",
            "id" => isset($user['id']) ? strval($user['id']) : "0",
            "NIP" => isset($user['NIP']) ? strval($user['NIP']) : "000000",
            "email" => $user['email'] ?? "no-email@example.com",
            "nama_depan" => $user['nama_depan'] ?? "Unknown",
            "Nama" => $user['Nama'] ?? "Unknown",
            "Jabatan" => $user['Jabatan'] ?? "Unknown",
            "Alamat" => $user['Alamat'] ?? "Unknown",
            "profile_picture" => $user['profile_picture'] ?? "default.jpg",
        ];
} else {
    $response = ["status" => "gagal", "message" => "Username tidak ditemukan"];
}

echo json_encode($response);
?>
