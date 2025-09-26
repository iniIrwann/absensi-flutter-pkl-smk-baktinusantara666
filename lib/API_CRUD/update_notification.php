<?php
include "db_utama.php";

header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data["id"]) && isset($data["user_id"])) {
        $id = intval($data["id"]);
        $user_id = intval($data["user_id"]);

        $sql = "UPDATE log_book SET status_notif = 'dibaca' WHERE id = ? AND user_id = ? AND solusi IS NOT NULL";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ii", $id, $user_id);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal memperbarui status"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "ID atau user_id tidak valid"]);
    }
}

$conn->close();
?>
