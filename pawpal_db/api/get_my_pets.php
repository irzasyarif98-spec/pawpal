<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

// Accept user_id or userId
$userId = $_GET['user_id'] ?? $_GET['userId'] ?? null;

if (!$userId || !is_numeric($userId)) {
    echo json_encode([
        'status'  => 'failed',
        'message' => 'User ID is required and must be numeric'
    ]);
    exit();
}

$userId = (int)$userId; // now it's integer

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

// THIS LINE WAS BROKEN IN YOUR CODE
$stmt->bind_param("i", $userId);  // "i" = integer, and exactly one variable

$stmt->execute();
$result = $stmt->get_result();

$pets = [];
while ($row = $result->fetch_assoc()) {
    // If image_paths is stored as JSON string, decode it
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


// $whereSql = '';
// if ($search !== '') {
//     // Use real_escape_string to avoid breaking the query
//     $s = $conn->real_escape_string($search);
//     $whereSql = " WHERE (p.pet_name LIKE '%$s%' OR p.pet_type LIKE '%$s%' OR p.category LIKE '%$s%' OR p.description LIKE '%$s%')";
// }

// Get total count for pagination
// $countSql = "SELECT COUNT(*) AS total FROM tbl_pets p JOIN tbl_users u ON p.user_id = u.user_id" . $whereSql;
// $countResult = $conn->query($countSql);
// $number_of_result = 0;
// if ($countResult) {
//     $r = $countResult->fetch_assoc();
//     $number_of_result = isset($r['total']) ? intval($r['total']) : 0;
// }
// $number_of_page = $number_of_result > 0 ? intval(ceil($number_of_result / $results_per_page)) : 1;

// // Final select with ordering and limit
// $sqlloadservices = $baseQuery . $whereSql . " ORDER BY p.pet_id DESC LIMIT $page_first_result, $results_per_page";

// $result = $conn->query($baseQuery);

// if ($result) {
//     $servicedata = array();
//     while ($row = $result->fetch_assoc()) {
//         $servicedata[] = $row;
//     }
//     $response = array('status' => 'success', 'data' => $servicedata, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
//     sendJsonResponse($response);
// } else {
//     $response = array('status' => 'failed', 'data' => null, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
//     sendJsonResponse($response);
// }

// function sendJsonResponse($sentArray)
// {
//     header('Content-Type: application/json');
//     echo json_encode($sentArray);
// }
?>