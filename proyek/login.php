<?php 
header('Content-Type: application/json');

// Koneksi ke database
require 'koneksi.php';

// Ambil data dari request
$username = isset($_POST['username']) ? $_POST['username'] : null;
$password = isset($_POST['password']) ? $_POST['password'] : null;

if ($username === null || $password === null) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

// Query untuk memeriksa apakah username dan password cocok
$query = $conn->prepare("SELECT Role FROM users WHERE Username = ? AND Password = ?");
$query->bind_param("ss", $username, $password);
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    // Login berhasil, kirimkan peran pengguna
    echo json_encode(['status' => 'success', 'role' => $row['Role'], 'message' => 'Login successful']);
} else {
    // Login gagal
    echo json_encode(['status' => 'error', 'message' => 'Invalid username or password']);
}

$query->close();
$conn->close();
?>
