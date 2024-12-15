<?php
header('Content-Type: application/json');
include 'koneksi.php';

$data = json_decode(file_get_contents('php://input'), true);

$nama = $data['nama'];
$totalHarga = $data['total_harga'];
$keranjang = $data['keranjang'];

if (empty($nama) || empty($keranjang)) {
    echo json_encode(['error' => 'Nama pembeli atau keranjang tidak boleh kosong']);
    exit;
}

$conn->autocommit(false);
try {
    // Simpan ke tabel pesan
    $stmtPesan = $conn->prepare("INSERT INTO pesan (nama, tgl_order, total_harga) VALUES (?, NOW(), ?)");
    $stmtPesan->bind_param("sd", $nama, $totalHarga);
    $stmtPesan->execute();
    $idPesan = $conn->insert_id;

    // Simpan ke tabel pesan_detail dan perbarui stok
    $stmtDetail = $conn->prepare("INSERT INTO pesan_detail (id_pesan, id_menu, jumlah, harga, total_harga) VALUES (?, ?, ?, ?, ?)");
    $stmtUpdateStok = $conn->prepare("UPDATE menu SET stok = stok - ? WHERE id_menu = ?");

    foreach ($keranjang as $item) {
        $idMenu = $item['id_menu'];
        $jumlah = $item['jumlah'];
        $harga = $item['harga'];
        $total = $item['total_harga'];

        $stmtDetail->bind_param("iiiii", $idPesan, $idMenu, $jumlah, $harga, $total);
        $stmtDetail->execute();

        $stmtUpdateStok->bind_param("ii", $jumlah, $idMenu);
        $stmtUpdateStok->execute();
    }

    $conn->commit();
    echo json_encode(['success' => 'Pesanan berhasil disimpan']);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['error' => 'Terjadi kesalahan saat menyimpan pesanan']);
}
$conn->close();
?>
