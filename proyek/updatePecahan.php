<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require 'koneksi.php'; // Pastikan koneksi database sudah diatur dengan benar

// Ambil data dari request
$data = json_decode(file_get_contents("php://input"), true);

// Validasi input data
if (!isset($data['pecahan']) || !is_array($data['pecahan'])) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid input data",
    ]);
    exit;
}

$pecahanList = $data['pecahan'];

$conn->autocommit(false); // Mulai transaksi

try {
    // Loop untuk memperbarui setiap pecahan
    foreach ($pecahanList as $pecahan) {
        if (!isset($pecahan['pecahan']) || !isset($pecahan['jumlah'])) {
            throw new Exception("Invalid pecahan data");
        }

        $nominal = intval($pecahan['pecahan']);
        $jumlah = intval($pecahan['jumlah']);

        // Update jumlah pecahan di database
        $updateQuery = "UPDATE pecahan SET jumlah = jumlah + ? WHERE pecahan = ?";
        $stmt = $conn->prepare($updateQuery);
        $stmt->bind_param("ii", $jumlah, $nominal);
        $stmt->execute();

        if ($stmt->affected_rows <= 0) {
            throw new Exception("Failed to update pecahan: $nominal");
        }
    }

    $conn->commit(); // Commit transaksi jika semua berhasil

    echo json_encode([
        "success" => true,
        "message" => "Pecahan updated successfully",
    ]);
} catch (Exception $e) {
    $conn->rollback(); // Rollback transaksi jika ada error
    echo json_encode([
        "success" => false,
        "message" => "Error updating pecahan: " . $e->getMessage(),
    ]);
}

$conn->close();
?>
