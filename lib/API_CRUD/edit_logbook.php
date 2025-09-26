<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

require 'db_utama.php';

$id = $_POST["user_id"];  
$tanggal = $_POST["tanggal"];
$waktu = $_POST["waktu"];
$kegiatan = $_POST["kegiatan"];
$kendala = $_POST["kendala"];
$solusi = $_POST["solusi"];

$query = "UPDATE log_book SET 
          waktu='$waktu', kegiatan='$kegiatan', 
          kendala='$kendala', solusi='$solusi' 
          WHERE user_id='$id' AND tanggal='$tanggal'";

$data = mysqli_query($conn, $query);

if ($data && mysqli_affected_rows($conn) > 0) {
    echo json_encode(["success" => true, "message" => "Data berhasil diupdate"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal update atau tidak ada perubahan"]);
}
?>
