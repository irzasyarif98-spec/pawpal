<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

$userId = $_GET['user_id'] ?? $_GET['userId'] ?? null;

if (!$userId || !is_numeric($userId)) {
    echo json_encode([
        'status'  => 'failed',
        'message' => 'User ID is required and must be numeric'
    ]);
    exit();
}

$userId = (int)$userId; 

$sql = "SELECT 
            pet_id,
            user_id,
            pet_name,
            pet_type,
            category,
            description,
            image_paths,
            lat,
            lng
        FROM tbl_pets 
        WHERE user_id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
    exit();
}

$stmt->bind_param("i", $userId);

$stmt->execute();
$result = $stmt->get_result();

$pets = [];
while ($row = $result->fetch_assoc()) {
    if (!empty($row['image_paths'])) {
        $decoded = json_decode($row['image_paths'], true);
        $row['image_paths'] = $decoded ?: explode(',', trim($row['image_paths']));
    }
    $pets[] = $row;
}

echo json_encode([
    'status' => 'success',
    'data'   => $pets
]);

$stmt->close();
$conn->close();

?>