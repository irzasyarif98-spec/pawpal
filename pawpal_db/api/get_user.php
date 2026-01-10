<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

$user_id = $_GET['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['status' => 'failed', 'message' => 'User ID is required']);
    exit();
}

$sql = "SELECT 
            user_id, 
            email, 
            name, 
            phone, 
            reg_date, 
            profile_image_path 
        FROM tbl_users 
        WHERE user_id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
    exit();
}

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
if ($row = $result->fetch_assoc()) {
    $data[] = $row;
    echo json_encode([
        'status' => 'success',
        'data'   => $data
    ]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'User not found']);
}

$stmt->close();
$conn->close();
?>