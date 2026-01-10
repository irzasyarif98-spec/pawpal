<?php
    header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

    if ($_SERVER['REQUEST_METHOD'] != 'GET') {
        http_response_code(405);
        echo json_encode(array('error' => 'Method Not Allowed'));
        exit();
    }

    $user_id = $_GET['user_id'] ?? null;
    $pet_id = $_GET['pet_id'] ?? null;
    $owner_user_id = $_GET['owner_user_id'] ?? null;
    $approved = $_GET['approved'] ?? null;


    $sql = "SELECT 
                id,
                pet_id,
                user_id,
                owner_user_id,
                `message`,
                approved
            FROM tbl_adoptions
            WHERE 1=1";

    $params = [];
    $types = "";

    if (!empty($user_id) && is_numeric($user_id)) {
        $user_id = (int)$user_id;
        $sql .= " AND user_id = ?";
        $params[] = $user_id;
        $types .= "i";
    }

    if (!empty($pet_id) && is_numeric($pet_id)) {
        $pet_id = (int)$pet_id;
        $sql .= " AND pet_id = ?";
        $params[] = $pet_id;
        $types .= "i";
    }

    if (!empty($owner_user_id) && is_numeric($owner_user_id)) {
        $owner_user_id = (int)$owner_user_id;
        $sql .= " AND owner_user_id = ?";
        $params[] = $owner_user_id;
        $types .= "i";
    }

    if (isset($approved)) {
        if ($approved === 'null') {
            $sql .= " AND approved IS NULL";
        } else if (is_numeric($approved)) {
            $approved = (int)$approved;
            $sql .= " AND approved = ?";
            $params[] = $approved;
            $types .= "i";
        }
    }


    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(['status' => 'failed', 'message' => 'Prepare failed: ' . $conn->error]);
        exit();
    }

    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    $adoptions = [];
    while ($row = $result->fetch_assoc()) {
        $adoptions[] = $row;
    }

    echo json_encode([
        'status' => 'success',
        'data'   => $adoptions
    ]);

    $stmt->close();
    $conn->close();

    function sendJsonResponse($sentArray) {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }