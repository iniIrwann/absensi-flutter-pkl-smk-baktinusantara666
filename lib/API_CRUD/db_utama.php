<?php
header("Access-Control-Allow-Origin: *");

$host = "localhost";       // Nama host (server)
$user = "root";            // Nama pengguna MySQL (default: root)
$password = "";            // Password MySQL (kosong jika menggunakan XAMPP)
$database = "absensi_agp"; // Nama database yang akan diakses

// Membuat koneksi
$conn = new mysqli($host, $user, $password, $database);

// Memeriksa koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
// echo "Koneksi berhasil!";
?>
