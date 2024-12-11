<?php
header('Content-Type: application/json');
include 'koneksi.php'; // Koneksi ke database menggunakan MySQLi

// Mendapatkan id_pesan dari parameter URL
if (isset($_GET['id_pesan'])) {
    $idPesan = $_GET['id_pesan'];

    // Query untuk mendapatkan detail pesanan berdasarkan id_pesan
    $query = "
        SELECT m.id_menu, m.nama AS nama_menu, d.jumlah, m.harga, (d.jumlah * m.harga) AS total_harga
        FROM pesan_detail d
        JOIN menu m ON d.id_menu = m.id_menu
        WHERE d.id_pesan = ?";

    // Menyiapkan statement menggunakan MySQLi
    if ($stmt = $conn->prepare($query)) {
        // Mengikat parameter
        $stmt->bind_param("i", $idPesan);

        // Menjalankan query dan mengambil hasil
        try {
            $stmt->execute();
            $result = $stmt->get_result();
            $detailPesanan = [];

            // Mengecek apakah ada data yang ditemukan
            while ($row = $result->fetch_assoc()) {
                $detailPesanan[] = $row;
            }

            if (count($detailPesanan) > 0) {
                echo json_encode([
                    "status" => "success",
                    "data" => $detailPesanan
                ]);
            } else {
                echo json_encode([
                    "status" => "error",
                    "message" => "No details found for this order."
                ]);
            }

            $stmt->close();
        } catch (Exception $e) {
            echo json_encode([
                "status" => "error",
                "message" => 'Database query failed: ' . $e->getMessage()
            ]);
        }
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to prepare the SQL query."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "id_pesan parameter is missing"
    ]);
}
?>
