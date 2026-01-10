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
$pet_id     = $_POST['pet_id'] ?? null;
$type       = $_POST['type'] ?? null;            // e.g. Food | Medical | Money
$amount     = $_POST['amount'] ?? null;          // decimal(11,2), nullable
$description = $_POST['description'] ?? null;    // TEXT, nullable

// Validate required fields
if ($pet_id === null || !is_numeric($pet_id)) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing or invalid pet_id']);
    exit();
}

if ($type === null || $type === '') {
    echo json_encode(['status' => 'failed', 'message' => 'Missing donation type']);
    exit();
}

// Optional: restrict allowed types
$allowedTypes = ['Food', 'Medical', 'Money'];
if (!in_array($type, $allowedTypes, true)) {
    echo json_encode(['status' => 'failed', 'message' => 'Invalid donation type']);
    exit();
}

// Enforce per-type requirements
// If Money, amount must be a positive number; description optional (TEXT)
if ($type === 'Money') {
    if ($amount === null || !is_numeric($amount) || (float)$amount <= 0) {
        echo json_encode(['status' => 'failed', 'message' => 'Invalid or missing amount for Money donation']);
        exit();
    }
    $amount = number_format((float)$amount, 2, '.', '');
    // description remains optional and can be any text
} else {
    // Non-money: amount should be NULL; description optional (TEXT)
    $amount = null;
}

// Normalize types
$pet_id = (int)$pet_id;
// Normalize description to TEXT (ignored for Money donations)
$descText = ($type === 'Money') ? null : (($description === null || trim($description) === '') ? null : trim($description));
// status tinyint(1) NOT NULL, default to 0 (pending)
$status = 0;

// Prepare insert
// Build SQL and bindings to set the correct NULL column
if ($type === 'Money') {
    // description should be NULL
    $sql = "INSERT INTO tbl_donations (pet_id, type, amount, description, status) VALUES (?, ?, ?, NULL, ?)";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
        exit();
    }
    // Bind: i s d i
    $stmt->bind_param(
        'isdi',
        $pet_id,
        $type,
        $amount,
        $status
    );
} else {
    // amount should be NULL
    $sql = "INSERT INTO tbl_donation_requests (pet_id, type, amount, description, status) VALUES (?, ?, NULL, ?, ?)";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
        exit();
    }
    // Bind: i s s i
    $stmt->bind_param(
        'issi',
        $pet_id,
        $type,
        $descText,
        $status
    );
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
    'message' => 'Donation request submitted',
    'id' => $insertId
]);

?>