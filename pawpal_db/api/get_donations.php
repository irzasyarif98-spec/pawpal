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
$donation_id = $_GET['donation_id'] ?? null;
$user_id = $_GET['user_id'] ?? null;

$sql = "SELECT 
            id,
            donation_id,
            amount,
            user_id
        FROM tbl_donation_history
        WHERE 1=1";

$params = [];
$types = "";

if (!empty($id) && is_numeric($id)) {
    $id = (int)$id;
    $sql .= " AND id = ?";
    $params[] = $id;
    $types .= "i";
}

if (!empty($donation_id) && is_numeric($donation_id)) {
    $donation_id = (int)$donation_id;
    $sql .= " AND donation_id = ?";
    $params[] = $donation_id;
    $types .= "i";
}

if (!empty($user_id) && is_numeric($user_id)) {
    $user_id = (int)$user_id;
    $sql .= " AND user_id = ?";
    $params[] = $user_id;
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
