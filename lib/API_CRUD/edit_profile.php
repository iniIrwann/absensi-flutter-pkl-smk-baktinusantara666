<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'db_utama.php'; // File koneksi database

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'] ?? ''; // Ambil ID dari POST
    if (!is_numeric($id)) {
        $response['error'] = true;
        $response['message'] = "ID tidak valid.";
        echo json_encode($response);
        exit;
    }

    $nip = $_POST['nip'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? ''; // Jangan update jika kosong
    $firstname = $_POST['nama_depan'] ?? '';
    $name = $_POST['nama'] ?? '';
    $jabatan = $_POST['jabatan'] ?? '';
    $alamat = $_POST['alamat'] ?? '';
    $profile_picture = '';

    // Cek apakah ada file yang diunggah
    if (isset($_FILES['profile_picture']) && $_FILES['profile_picture']['size'] > 0) {
        $target_dir = "uploads_utama/";
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        $file_name = time() . "_" . basename($_FILES["profile_picture"]["name"]);
        $target_file = $target_dir . $file_name;
        $full_url = "http://192.168.152.19/API_CRUD/" . $target_file; // Path lengkap

        if (move_uploaded_file($_FILES["profile_picture"]["tmp_name"], $target_file)) {
            $profile_picture = $full_url;
        } else {
            $response['error'] = true;
            $response['message'] = "Gagal mengunggah gambar.";
            echo json_encode($response);
            exit;
        }
    } else {
        // Jika tidak ada gambar baru, gunakan gambar lama dari database
        $query = $conn->prepare("SELECT profile_picture FROM pegawai WHERE id = ?");
        $query->bind_param("i", $id);
        $query->execute();
        $result = $query->get_result();
        if ($row = $result->fetch_assoc()) {
            $profile_picture = $row['profile_picture'];
        }
        $query->close();
    }

    // Periksa apakah password kosong atau tidak
    if (!empty($password)) {
        // $hashed_password = password_hash($password, PASSWORD_DEFAULT); // Hash password
        $sql = "UPDATE pegawai SET NIP=?, email=?, password=?, nama_depan=?, Nama=?, Jabatan=?, Alamat=?, profile_picture=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssssssi", $nip, $email, $password, $firstname, $name, $jabatan, $alamat, $profile_picture, $id);
    } else {
        $sql = "UPDATE pegawai SET NIP=?, email=?, password=? nama_depan=?, Nama=?, Jabatan=?, Alamat=?, profile_picture=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssssssi", $nip, $email, $password, $firstname, $name, $jabatan, $alamat, $profile_picture, $id);
    }

    if ($stmt->execute()) {
        $response['error'] = false;
        $response['message'] = "Profil berhasil diperbarui.";
        $response['image_url'] = $profile_picture; // Kembalikan path gambar baru
    } else {
        $response['error'] = true;
        $response['message'] = "Gagal memperbarui profil.";
    }

    $stmt->close();
} else {
    $response['error'] = true;
    $response['message'] = "Metode tidak diizinkan.";
}

echo json_encode($response);
$conn->close();
?>
