<?php
include 'koneksi.php'; 
$id = isset($_REQUEST['id']) ? intval($_REQUEST['id']) : null;
                
                    if ($id) {
                        $query = "DELETE FROM menu WHERE id_menu = ?";
                        $stmt = $conn->prepare($query);
                        $stmt->bind_param("i", $id);
                
                        if ($stmt->execute()) {
                            echo json_encode(["status" => "success", "message" => "Menu berhasil dihapus"]);
                        } else {
                            echo json_encode(["status" => "error", "message" => "Gagal menghapus menu"]);
                        }
                    } else {
                        echo json_encode(["status" => "error", "message" => "ID menu tidak diberikan"]);
                    }
