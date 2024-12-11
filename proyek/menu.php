<?php
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);
require_once "koneksi.php"; // File konfigurasi database

$response = ["status" => "error", "data" => null];

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        if (isset($_GET['id'])) {
            $id = intval($_GET['id']);
            $query = "SELECT * FROM menu WHERE id_menu = ?";
            $stmt = $conn->prepare($query);
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $result = $stmt->get_result();
            $data = $result->fetch_assoc();
            $response["status"] = "success";
            $response["data"] = $data ?: [];
        } else {
            $query = "SELECT * FROM menu";
            $result = $conn->query($query);
            $data = $result->fetch_all(MYSQLI_ASSOC);
            $response["status"] = "success";
            $response["data"] = $data;
        }
        break;

        case 'POST':
            // Menambahkan menu baru dengan upload file gambar
            if (
                isset($_POST['nama'], $_POST['kategori'], $_POST['harga'], $_POST['stok']) && 
                isset($_FILES['gambar'])
            ) {
                // Menentukan folder penyimpanan gambar
                $uploadDir = __DIR__ . '/uploads/';
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0777, true);
                }
        
                // Menyimpan gambar yang diunggah
                $fileName = basename($_FILES['gambar']['name']);
                $targetFile = $uploadDir . $fileName;
        
                // Mengunggah file gambar
                if (move_uploaded_file($_FILES['gambar']['tmp_name'], $targetFile)) {
                    $gambarPath = 'uploads/' . $fileName; // Path relatif untuk gambar
        
                    // Insert menu baru ke database
                    $query = "INSERT INTO menu (nama, kategori, harga, stok, gambar, created_at, updated_at)
                                VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
                    $stmt = $conn->prepare($query);
                    $stmt->bind_param(
                        "ssdis",
                        $_POST['nama'],
                        $_POST['kategori'],
                        $_POST['harga'],
                        $_POST['stok'],
                        $gambarPath
                    );
        
                    if ($stmt->execute()) {
                        echo json_encode(["status" => "success", "message" => "Menu berhasil ditambahkan"]);
                    } else {
                        echo json_encode(["status" => "error", "message" => "Gagal menambahkan menu ke database"]);
                    }
                } else {
                    echo json_encode(["status" => "error", "message" => "Gagal mengunggah gambar"]);
                }
            } else {
                echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
            }
            break;       
        }
echo json_encode($response);
?>