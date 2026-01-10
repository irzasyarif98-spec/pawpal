<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

$id = $_GET['id'] ?? null;
$pet_id = $_GET['pet_id'] ?? null;
$user_id = $_GET['user_id'] ?? null;
$type = $_GET['type'] ?? null;
$status = $_GET['status'] ?? null;

$sql = "SELECT 
            id,
            pet_id,
            user_id,
            type,
            amount,
            description,
            status
        FROM tbl_donations
        WHERE 1=1";

$params = [];
$types = "";

if (!empty($id) && is_numeric($id)) {
    $id = (int)$id;
    $sql .= " AND id = ?";
    $params[] = $id;
    $types .= "i";
}

if (!empty($pet_id) && is_numeric($pet_id)) {
    $pet_id = (int)$pet_id;
    $sql .= " AND pet_id = ?";
    $params[] = $pet_id;
    $types .= "i";
}

if (!empty($user_id) && is_numeric($user_id)) {
    $user_id = (int)$user_id;
    $sql .= " AND user_id = ?";
    $params[] = $user_id;
    $types .= "i";
}

if (!empty($type) && is_string($type)) {
    $allowedTypes = ['Food', 'Medical', 'Money'];
    if (in_array($type, $allowedTypes, true)) {
        $sql .= " AND type = ?";
        $params[] = $type;
        $types .= "s";
    }
}

if (!empty($status) && is_numeric($status)) {
    $status = (int)$status;
    $sql .= " AND status = ?";
    $params[] = $status;
    $types .= "i";
}

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
    exit();
}

if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$donations = [];
while ($row = $result->fetch_assoc()) {
    $donations[] = $row;
}

echo json_encode([
    'status' => 'success',
    'data'   => $donations
]);

$stmt->close();
$conn->close();

?>
