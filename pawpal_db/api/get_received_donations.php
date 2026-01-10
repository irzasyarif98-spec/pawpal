<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

$response = [
  'status' => 'error',
  'message' => 'Unknown error',
  'data' => []
];

$ownerUserId = null;
if (isset($_GET['owner_user_id'])) {
  $ownerUserId = trim($_GET['owner_user_id']);
} elseif (isset($_GET['user_id'])) { // fallback for compatibility
  $ownerUserId = trim($_GET['user_id']);
}

if ($ownerUserId === null || $ownerUserId === '') {
  $response['message'] = 'Missing required parameter: owner_user_id';
  echo json_encode($response);
  exit;
}

// TODO: Adjust these credentials to match your local XAMPP MySQL setup
$DB_HOST = 'localhost';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'pawpal_db';

$conn = @new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($conn->connect_error) {
  $response['message'] = 'Database connection failed';
  echo json_encode($response);
  exit;
}

// Ensure proper collation/charset if needed
$conn->set_charset('utf8mb4');

// Query: donations received for pets owned by ownerUserId
// donation_history.donation_id = donations.id AND donations.user_id = ownerUserId
$sql = "
  SELECT 
    dh.id AS id,
    dh.donation_id AS donation_id,
    dh.user_id AS user_id, -- donor user id
    dh.amount AS amount,
    d.user_id AS donation_owner_user_id,
    d.pet_id AS pet_id,
    d.type AS type,
    d.description AS description
  FROM tbl_donation_history dh
  INNER JOIN tbl_donations d ON dh.donation_id = d.id
  WHERE d.user_id = ?
  ORDER BY dh.id DESC
";

$stmt = $conn->prepare($sql);
if (!$stmt) {
  $response['message'] = 'Failed to prepare statement';
  echo json_encode($response);
  $conn->close();
  exit;
}

$stmt->bind_param('s', $ownerUserId);

if (!$stmt->execute()) {
  $response['message'] = 'Failed to execute query';
  echo json_encode($response);
  $stmt->close();
  $conn->close();
  exit;
}

$result = $stmt->get_result();
$data = [];
while ($row = $result->fetch_assoc()) {
  // Normalize amount to string or null to match frontend expectations
  if ($row['amount'] === null) {
    $row['amount'] = null;
  } else {
    $row['amount'] = (string)$row['amount'];
  }
  $data[] = $row;
}

$stmt->close();
$conn->close();

$response['status'] = 'success';
$response['message'] = 'Donations retrieved';
$response['data'] = $data;

echo json_encode($response);
