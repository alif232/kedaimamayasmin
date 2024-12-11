<?php
include 'koneksi.php'; // Include file koneksi ke database

// Pastikan semua data yang diperlukan ada dalam POST request
if (isset($_POST['id_menu'], $_POST['nama'], $_POST['kategori'], $_POST['harga'], $_POST['stok'])) {
    $idMenu = intval($_POST['id_menu']);
    $nama = $_POST['nama'];
    $kategori = $_POST['kategori'];
    $harga = $_POST['harga'];
    $stok = $_POST['stok'];
    $gambarPath = $_POST['gambar'] ?? ''; // Gambar lama jika tidak diubah

    // Jika ada gambar baru, proses upload gambar
    if (isset($_FILES['gambar']) && $_FILES['gambar']['error'] == 0) {
        $uploadDir = __DIR__ . '/uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        // Hapus gambar lama jika ada
        if (!empty($gambarPath)) {
            $oldFile = $uploadDir . basename($gambarPath);
            if (file_exists($oldFile)) {
                unlink($oldFile); // Hapus gambar lama
            }
        }

        // Proses upload gambar baru
        $fileName = basename($_FILES['gambar']['name']);
        $targetFile = $uploadDir . $fileName;

        if (move_uploaded_file($_FILES['gambar']['tmp_name'], $targetFile)) {
            $gambarPath = 'uploads/' . $fileName; // Ganti dengan path gambar baru
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal mengunggah gambar baru"]);
            exit;
        }
    }

    // Update data menu
    $updateQuery = "UPDATE menu 
                    SET nama = ?, kategori = ?, harga = ?, stok = ?, gambar = ?, updated_at = NOW() 
                    WHERE id_menu = ?";
    $updateStmt = $conn->prepare($updateQuery);
    $updateStmt->bind_param("ssdisi", $nama, $kategori, $harga, $stok, $gambarPath, $idMenu);

    if ($updateStmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Menu berhasil diperbarui"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal memperbarui menu"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
}
?>
