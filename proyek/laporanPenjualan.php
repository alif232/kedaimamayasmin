<?php
header('Content-Type: application/json');
include 'koneksi.php';

// Query untuk mendapatkan data dari tabel pesan saja
$query = "
    SELECT id_pesan, nama, tgl_order, total_harga
    FROM pesan
    ORDER BY tgl_order DESC
";

$result = $conn->query($query);

$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode([
    "status" => "success",
    "data" => $data,
]);

$conn->close();
?>
