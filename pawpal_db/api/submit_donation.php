<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include 'dbconnect.php';

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
	http_response_code(405);
	echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
	exit();
}

// Read inputs
$donation_id = $_POST['donation_id'] ?? null; // refers to an existing donation request/id
$amount      = $_POST['amount'] ?? null;      // decimal(10,0), nullable unless Money
$user_id     = $_POST['user_id'] ?? null;     // donor user id

// Validate
if ($donation_id === null || !is_numeric($donation_id)) {
	echo json_encode(['status' => 'failed', 'message' => 'Missing or invalid donation_id']);
	exit();
}

if ($user_id === null || !is_numeric($user_id)) {
	echo json_encode(['status' => 'failed', 'message' => 'Missing or invalid user_id']);
	exit();
}

// Normalize types
$donation_id = (int)$donation_id;
$user_id = (int)$user_id;

// Determine donation type: Money vs Non-money
$isMoney = false;

// Check tbl_donations (Money donations)
$checkMoney = $conn->prepare("SELECT id FROM tbl_donations WHERE id = ? LIMIT 1");
if ($checkMoney) {
	$checkMoney->bind_param('i', $donation_id);
	$checkMoney->execute();
	$checkMoney->store_result();
	if ($checkMoney->num_rows > 0) {
		$isMoney = true;
	}
	$checkMoney->close();
}

if (!$isMoney) {
	// Check non-money donation requests
	$checkReq = $conn->prepare("SELECT id FROM tbl_donation_requests WHERE id = ? LIMIT 1");
	if ($checkReq) {
		$checkReq->bind_param('i', $donation_id);
		$checkReq->execute();
		$checkReq->store_result();
		if ($checkReq->num_rows === 0) {
			echo json_encode(['status' => 'failed', 'message' => 'Donation reference not found']);
			$checkReq->close();
			$conn->close();
			exit();
		}
		$checkReq->close();
	} else {
		echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
		$conn->close();
		exit();
	}
}

// Validate amount only for Money
if ($isMoney) {
	if ($amount === null || !is_numeric($amount) || (float)$amount <= 0) {
		echo json_encode(['status' => 'failed', 'message' => 'Invalid or missing amount for money donation']);
		$conn->close();
		exit();
	}
}

// decimal(10,0) has zero scale → store as integer when provided
$amount_int = ($isMoney) ? (int)round((float)$amount) : null;

// Insert into tbl_donation_history (donation_id, amount, user_id)
if ($isMoney) {
	// Amount required and provided
	$sql = "INSERT INTO tbl_donation_history (donation_id, amount, user_id) VALUES (?, ?, ?)";
	$stmt = $conn->prepare($sql);
	if (!$stmt) {
		echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
		exit();
	}
	$stmt->bind_param('iii', $donation_id, $amount_int, $user_id);
} else {
	// Non-money: amount must be NULL
	$sql = "INSERT INTO tbl_donation_history (donation_id, amount, user_id) VALUES (?, NULL, ?)";
	$stmt = $conn->prepare($sql);
	if (!$stmt) {
		echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
		exit();
	}
	$stmt->bind_param('ii', $donation_id, $user_id);
}

if (!$stmt->execute()) {
	echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
	$stmt->close();
	$conn->close();
	exit();
}

$insertId = $stmt->insert_id;
$stmt->close();
$conn->close();

echo json_encode([
	'status' => 'success',
	'message' => 'Donation recorded successfully',
	'id' => $insertId
]);

?>
