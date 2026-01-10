<?php
	header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}
	if (!isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
		http_response_code(400);
		echo json_encode(array('error' => 'Bad Request'));
		exit();
	}

	$email = $_POST['email'];
	$name = $_POST['name'];
	$phone = $_POST['phone'];
	$password = $_POST['password'];
	$hashedpassword = sha1($password);
	$profile_image = $_POST['profile_image'] ?? '';
	

	$checkemail = "SELECT * FROM `tbl_users` WHERE `email` = '$email'";
	$result = $conn->query($checkemail);
	if ($result->num_rows > 0){
		$response = array('status' => 'failed', 'message' => 'Email already registered.');
		sendJsonResponse($response);
		exit();
	}
	// Insert user with a prepared statement
	$sqlregister = $conn->prepare("INSERT INTO `tbl_users`(`email`, `name`, `phone`, `password`) VALUES (?,?,?,?)");
	$sqlregister->bind_param("ssss", $email, $name, $phone, $hashedpassword);
	
	try{
		if ($sqlregister->execute()){
			$userId = $conn->insert_id;
			$uploadDir = 'uploads/users/';
			if (!is_dir($uploadDir)) {
				@mkdir($uploadDir, 0777, true);
			}

			if (empty($profile_image)) {
				$profileImagePath = 'uploads/users/default.webp';
			} else {
				$decodedimage = base64_decode($profile_image, true);

				if ($decodedimage === false) {
					$response = array('status' => 'failed', 'message' => 'Invalid image format.');
					sendJsonResponse($response);
					exit();
				}
				$profileImagePath = $uploadDir . 'pp_' . $userId . '.png';
				if (file_put_contents($profileImagePath, $decodedimage) === false) {
					$response = array('status' => 'failed', 'message' => 'Failed to save profile image.');
					sendJsonResponse($response);
					exit();
				}
			}
			
			$sqlupdate = "UPDATE tbl_users SET profile_image_path = '$profileImagePath' WHERE user_id = '$userId'";
            
            if ($conn->query($sqlupdate) === FALSE) {
                $response = array('status' => 'failed', 'message' => 'Failed to save image paths to database.');
                sendJsonResponse(sentArray: $response);
                exit();
            }
		
			$sqlregister->close();
			


			$response = array(
				'status' => 'success',
				'message' => 'User registered successfully.',
				'user_id' => $userId,
				'profile_image_path' => $profileImagePath
			);
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'message' => 'User registration failed.');
			sendJsonResponse($response);
		}
	}catch(Exception $e){
		$response = array('status' => 'failed', 'message' => $e->getMessage());
		sendJsonResponse($response);
	}

	function sendJsonResponse($sentArray)
	{
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}
?>