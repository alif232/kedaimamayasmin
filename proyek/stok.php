<?php
include 'koneksi.php'; // File koneksi ke database

header("Content-Type: application/json");

// Mendapatkan metode HTTP yang digunakan
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Mengambil data stok dari tabel menu
        $query = "SELECT id_menu, nama, stok FROM menu";
        $result = $conn->query($query);

        if ($result->num_rows > 0) {
            $stokList = [];
            while ($row = $result->fetch_assoc()) {
                $stokList[] = [
                    "id_menu" => $row['id_menu'],
                    "nama" => $row['nama'],
                    "stok" => (int)$row['stok'] // Memastikan stok dikirim sebagai integer
                ];
            }
            echo json_encode($stokList);
        } else {
            echo json_encode([]); // Jika tidak ada data
        }
        break;

    case 'POST':
        // Menambah stok
        if (isset($_POST['id_menu'], $_POST['jumlah_stok'])) {
            $idMenu = intval($_POST['id_menu']);
            $jumlahStok = intval($_POST['jumlah_stok']); // Pastikan jumlah stok adalah angka
            
            // Cek jika jumlah stok lebih besar dari 0
            if ($jumlahStok > 0) {
                // Mengambil stok saat ini
                $query = "SELECT stok FROM menu WHERE id_menu = ?";
                $stmt = $conn->prepare($query);
                $stmt->bind_param("i", $idMenu);
                $stmt->execute();
                $result = $stmt->get_result();

                if ($result->num_rows > 0) {
                    $row = $result->fetch_assoc();
                    $stokSekarang = $row['stok'];

                    // Menambah stok yang baru ke stok yang lama
                    $stokBaru = $stokSekarang + $jumlahStok;

                    // Update stok di database
                    $updateQuery = "UPDATE menu SET stok = ? WHERE id_menu = ?";
                    $updateStmt = $conn->prepare($updateQuery);
                    $updateStmt->bind_param("ii", $stokBaru, $idMenu);

                    if ($updateStmt->execute()) {
                        echo json_encode(["status" => "success", "message" => "Stok berhasil ditambahkan"]);
                    } else {
                        echo json_encode(["status" => "error", "message" => "Gagal memperbarui stok"]);
                    }
                } else {
                    echo json_encode(["status" => "error", "message" => "Menu tidak ditemukan"]);
                }
            } else {
                echo json_encode(["status" => "error", "message" => "Jumlah stok harus lebih besar dari 0"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "message" => "Metode HTTP tidak didukung"]);
        break;
}
?>
