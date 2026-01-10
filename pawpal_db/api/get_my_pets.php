<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

$userId = $_GET['user_id'] ?? $_GET['userId'] ?? null;
$petname = $_GET['petname'] ?? null;
$pettype = $_GET['pettype'] ?? null;
$petId = $_GET['pet_id'] ?? null;


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
        WHERE 1=1";

$params = [];
$types = "";

if (!empty($userId) && is_numeric($userId)) {
    $userId = (int)$userId;
    $sql .= " AND user_id = ?";
    $params[] = $userId;
    $types .= "i";
}

if (!empty($petname)) {
    $sql .= " AND pet_name LIKE ?";
    $params[] = "%$petname%";
    $types .= "s";
}

if (!empty($pettype) && $pettype !== 'All') {
    $sql .= " AND pet_type = ?";
    $params[] = $pettype;
    $types .= "s";
}

if (!empty($petId) && is_numeric($petId)) {
    $petId = (int)$petId;
    $sql .= " AND pet_id = ?";
    $params[] = $petId;
    $types .= "i";
}

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
    exit();
}

if (!empty($types)) {
    $stmt->bind_param($types, ...$params);
}

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