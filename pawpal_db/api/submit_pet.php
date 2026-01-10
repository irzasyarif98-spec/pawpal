<?php
    header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}

    $userid = $_POST['userid'] ?? '';
    $petname = $_POST['petname'] ?? '';
    $pettype = $_POST['pettype'] ?? '';
    $category = $_POST['category'] ?? '';
    $description = $_POST['description'] ?? '';
    $image1 = $_POST['image1'] ?? '';
    $image2 = $_POST['image2'] ?? '';
    $image3 = $_POST['image3'] ?? '';
    $lat = $_POST['lat'] ?? '';
    $long = $_POST['long'] ?? '';

    if (empty($image1)) {
        $response = array('status' => 'failed', 'message' => 'At least one image is required.');
        sendJsonResponse($response);
        exit();
    }

    $decodedimage1 = base64_decode($image1, true);
    $decodedimage2 = !empty($image2) ? base64_decode($image2, true) : false;
    $decodedimage3 = !empty($image3) ? base64_decode($image3, true) : false;

    if ($decodedimage1 === false) {
        $response = array('status' => 'failed', 'message' => 'Invalid image format.');
        sendJsonResponse($response);
        exit();
    }

    $sqlinsert = "INSERT INTO tbl_pets (user_id, pet_name, pet_type, category, description, lat, lng) 
    VALUES ('$userid','$petname','$pettype','$category','$description', '$lat','$long')";

    try{
		if ($conn->query($sqlinsert) === TRUE){
			$id = $conn->insert_id;
            $uploadsDir = "uploads/pets/";
            if (!is_dir($uploadsDir)) {
                mkdir($uploadsDir, 0755, true);
            }

            $filename1 = $uploadsDir . "pet_" . $userid . "_" . $id . "_1.png";
            $filename2 = $uploadsDir . "pet_" . $userid . "_" . $id . "_2.png";
            $filename3 = $uploadsDir . "pet_" . $userid . "_" . $id . "_3.png";

            if (file_put_contents($filename1, $decodedimage1) === false) {
                $response = array('status' => 'failed', 'message' => 'Failed to save image 1.');
                sendJsonResponse($response);
                exit();
            }

            if ($decodedimage2 !== false) {
                if (file_put_contents($filename2, $decodedimage2) === false) {
                    $response = array('status' => 'failed', 'message' => 'Failed to save image 2.');
                    sendJsonResponse($response);
                    exit();
                }
            }

            if ($decodedimage3 !== false) {
                if (file_put_contents($filename3, $decodedimage3) === false) {
                    $response = array('status' => 'failed', 'message' => 'Failed to save image 3.');
                    sendJsonResponse($response);
                    exit();
                }
            }

            $imagePaths = array();
            if (file_exists($filename1)) $imagePaths[] = $filename1;
            if (file_exists($filename2)) $imagePaths[] = $filename2;
            if (file_exists($filename3)) $imagePaths[] = $filename3;
            
            $imagePathsJson = json_encode($imagePaths);

            $sqlupdate = "UPDATE tbl_pets SET image_paths = '$imagePathsJson' WHERE pet_id = '$id'";
            
            if ($conn->query($sqlupdate) === FALSE) {
                $response = array('status' => 'failed', 'message' => 'Failed to save image paths to database.');
                sendJsonResponse($response);
                exit();
            }

			$response = array(
                'status' => 'success', 
                'message' => 'Pet added successfully',
                'pet_id' => $id,
                'image_paths' => $imagePaths,
                'lat' => $lat,
                'lng' => $long
            );
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'message' => 'Pet not added');
			sendJsonResponse($response);
		} 
    } catch(Exception $e){
		$response = array('status' => 'failed', 'message' => $e->getMessage());
		sendJsonResponse($response);
    }

    function sendJsonResponse($sentArray)
    {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }
?>