<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require 'koneksi.php';

$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : '';

switch ($endpoint) {
    case 'pecahan':
        getPecahan($conn);
        break;

    case 'laporan_keuangan':
        getLaporanKeuangan($conn);
        break;

    case 'balance':
        getBalance($conn);
        break;

    case 'tambah_pengeluaran':
        addPengeluaran($conn);
        break;

    default:
        echo json_encode(["message" => "Invalid endpoint"]);
        break;
}

function getPecahan($conn) {
    $query = "SELECT * FROM pecahan";
    $result = $conn->query($query);
    $data = [];
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }
    echo json_encode($data);
}

function getLaporanKeuangan($conn) {
    $query = "SELECT * FROM laporan_keuangan ORDER BY tanggal DESC";
    $result = $conn->query($query);
    $data = [];
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }
    echo json_encode($data);
}

function getBalance($conn) {
    $query = "SELECT SUM(pecahan * jumlah) AS balance FROM pecahan";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        $balance = isset($row['balance']) && $row['balance'] !== null ? (int)$row['balance'] : 0;
        echo json_encode(["balance" => $balance]);
    } else {
        echo json_encode(["balance" => 0, "error" => "Query failed"]);
    }
}

function addPengeluaran($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    error_log("Received data: " . json_encode($data)); // Log input data

    if (isset($data['description'], $data['total_amount'], $data['pecahans']) && is_array($data['pecahans'])) {
        $description = $data['description'];
        $totalAmount = (int)$data['total_amount']; // Ambil totalAmount dari data
        $pecahans = $data['pecahans'];
        $conn->begin_transaction();

        try {
            // Masukkan total uang ke laporan_keuangan
            $stmt = $conn->prepare("INSERT INTO laporan_keuangan (deskripsi, tanggal, jumlah) VALUES (?, NOW(), ?)");
            $stmt->bind_param("si", $description, $totalAmount);
            $stmt->execute();

            if ($stmt->affected_rows <= 0) {
                throw new Exception("Failed to insert laporan_keuangan");
            }

            $laporanId = $conn->insert_id;
            error_log("Laporan ID: $laporanId");

            // Update jumlah di tabel pecahan
            foreach ($pecahans as $pecahan) {
                $pecahanId = $pecahan['pecahan_id'];
                $jumlah = (int)$pecahan['jumlah'];

                $updateStmt = $conn->prepare("UPDATE pecahan SET jumlah = jumlah - ? WHERE id_pecahan = ?");
                $updateStmt->bind_param("ii", $jumlah, $pecahanId);
                $updateStmt->execute();

                if ($updateStmt->affected_rows <= 0) {
                    throw new Exception("Failed to update pecahan");
                }
            }

            $conn->commit();
            echo json_encode(["message" => "Pengeluaran added successfully"]);
        } catch (Exception $e) {
            $conn->rollback();
            error_log("Rollback due to error: " . $e->getMessage());
            echo json_encode(["message" => "Failed to add pengeluaran", "error" => $e->getMessage()]);
        }
    } else {
        echo json_encode(["message" => "Invalid input data"]);
    }
}
