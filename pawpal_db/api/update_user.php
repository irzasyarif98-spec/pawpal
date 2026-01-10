<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

$response = [
  'status' => 'error',
  'message' => 'Unknown error',
];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  $response['message'] = 'Method not allowed';
  echo json_encode($response);
  exit;
}

include 'dbconnect.php';

// Get POST data
$userId = $_POST['user_id'] ?? null;
$name = $_POST['name'] ?? null;
$email = $_POST['email'] ?? null;
$phone = $_POST['phone'] ?? null;

// Validate required fields
if (!$userId || !$name || !$email || !$phone) {
  $response['message'] = 'Missing required fields';
  echo json_encode($response);
  exit;
}

// Sanitize inputs
$userId = trim($userId);
$name = trim($name);
$email = trim($email);
$phone = trim($phone);

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  $response['message'] = 'Invalid email format';
  echo json_encode($response);
  exit;
}

// Handle profile image upload
$profileImagePath = null;
if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
  $uploadDir = __DIR__ . '/uploads/users/';
  if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
  }

  $fileExtension = strtolower(pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION));
  $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  
  if (!in_array($fileExtension, $allowedExtensions)) {
    $response['message'] = 'Invalid file type. Only JPG, PNG, GIF, and WEBP are allowed.';
    echo json_encode($response);
    exit;
  }

  $newFileName = 'user_' . $userId . '_' . time() . '.' . $fileExtension;
  $uploadPath = $uploadDir . $newFileName;

  if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $uploadPath)) {
    $profileImagePath = 'uploads/users/' . $newFileName;
  } else {
    $response['message'] = 'Failed to upload image';
    echo json_encode($response);
    exit;
  }
}

// Update user in database
if ($profileImagePath) {
  $sql = "UPDATE tbl_users SET name = ?, email = ?, phone = ?, profile_image_path = ? WHERE user_id = ?";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param('ssssi', $name, $email, $phone, $profileImagePath, $userId);
} else {
  $sql = "UPDATE tbl_users SET name = ?, email = ?, phone = ? WHERE user_id = ?";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param('sssi', $name, $email, $phone, $userId);
}

if ($stmt->execute()) {
  if ($stmt->affected_rows > 0 || $stmt->affected_rows === 0) {
    $response['status'] = 'success';
    $response['message'] = 'Profile updated successfully';
    if ($profileImagePath) {
      $response['profile_image_path'] = $profileImagePath;
    }
  } else {
    $response['message'] = 'No changes made or user not found';
  }
} else {
  $response['message'] = 'Database error: ' . $stmt->error;
}

$stmt->close();
$conn->close();

echo json_encode($response);
?>
