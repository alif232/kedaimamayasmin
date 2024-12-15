<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require 'koneksi.php'; // Make sure this file contains the database connection

$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : '';

switch ($endpoint) {
    case 'pecahan':
        getPecahan($conn);
        break;
    default:
        echo json_encode(["message" => "Invalid endpoint"]);
        break;
}

// Function to fetch the pecahan data from the database
function getPecahan($conn) {
    // SQL query to select all pecahan data
    $query = "SELECT * FROM pecahan"; 
    $result = $conn->query($query);

    // Prepare an array to store the result
    $data = [];
    
    if ($result && $result->num_rows > 0) {
        // Loop through the result and add each row to the data array
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }
    
    // Return the data as a JSON response
    echo json_encode($data);
}
