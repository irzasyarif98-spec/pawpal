<?php
    header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}

    $pet_id = $_POST['pet_id'] ?? '';
    $user_id = $_POST['user_id'] ?? '';
    $owner_user_id = $_POST['owner_user_id'] ?? '';
    $message = $_POST['message'] ?? '';

    $sqlinsert = "INSERT INTO tbl_adoptions (pet_id, user_id, owner_user_id, message)
    VALUES ('$pet_id', '$user_id', '$owner_user_id', '$message')";
    
    try{
        if ($conn->query($sqlinsert) === TRUE){
            $response = array('status' => 'success', 'message' => 'Adoption request submitted successfully.');
            sendJsonResponse($response);
            exit();
        } else {
            $response = array('status' => 'failed', 'message' => 'Error submitting adoption request.');
            sendJsonResponse($response);
            exit();
        }
    } catch (Exception $e) {
        $response = array('status' => 'error', 'message' => 'An error occurred: ' . $e->getMessage());
        sendJsonResponse($response);
        exit();
    }

    function sendJsonResponse($sentArray) {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }