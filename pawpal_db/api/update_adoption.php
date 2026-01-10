<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
	http_response_code(405);
	echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
	exit();
}

$adoptionId = $_POST['adoption_id'] ?? null;
$approved   = $_POST['approved'] ?? null;

if ($adoptionId === null || !is_numeric($adoptionId)) {
	echo json_encode(['status' => 'failed', 'message' => 'Missing or invalid adoption_id']);
	exit();
}

// Normalize approved to int/null
if ($approved === null || $approved === '' || strtolower((string)$approved) === 'null') {
	$approved = null;
} elseif (in_array((string)$approved, ['0', '1'], true)) {
	$approved = (int)$approved;
} else {
	echo json_encode(['status' => 'failed', 'message' => 'Invalid approved value. Use 0, 1, or null']);
	exit();
}

// Build SQL depending on null/non-null approved
if ($approved === null) {
	$sql = "UPDATE tbl_adoptions SET approved = NULL WHERE id = ?";
	$stmt = $conn->prepare($sql);
	if (!$stmt) {
		echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
		exit();
	}
	$stmt->bind_param('i', $adoptionId);
} else {
	$sql = "UPDATE tbl_adoptions SET approved = ? WHERE id = ?";
	$stmt = $conn->prepare($sql);
	if (!$stmt) {
		echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
		exit();
	}
	$stmt->bind_param('ii', $approved, $adoptionId);
}

if ($stmt->execute()) {
	echo json_encode(['status' => 'success', 'message' => 'Adoption updated successfully']);
} else {
	echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();

?>
