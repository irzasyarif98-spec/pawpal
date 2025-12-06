<?php
    header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}

    $userid = $_POST['userid'];
    $petname = $_POST['petname'];
    $pettype = $_POST['pettype'];
    $category = $_POST['category'];
    $description = $_POST['description'];
    $image1 = $_POST['image1'];
    $image2 = $_POST['image2'];
    $image3 = $_POST['image3'];
    $decodedimage1 = base64_decode($image1);
    $decodedimage2 = base64_decode($image2);
    $decodedimage3 = base64_decode($image3);
    $lat = $_POST['lat'];
    $long = $_POST['long'];

    // Correct SQL: identifiers must not use single quotes. Use backticks or none.
    $sqlinsert = "INSERT INTO tbl_pets (user_id, pet_name, pet_type, category, description, lat, lng) 
    VALUES ('$userid','$petname','$pettype','$category','$description', '$lat','$long')";

    try{
		if ($conn->query($sqlinsert) === TRUE){
			$id = $conn->insert_id;
            $filename1 = "uploads/pets/pet_".$id."_1.png";
            $filename2 = "uploads/pets/pet_".$id."_2.png";
            $filename3 = "uploads/pets/pet_".$id."_3.png";
			file_put_contents($filename1, $decodedimage1);
            $decodedimage2 == false ?: file_put_contents($filename2, $decodedimage2);
            $decodedimage3 == false ?: file_put_contents($filename3, $decodedimage3);


			$response = array('status' => 'success', 'message' => 'Pet added successfully');
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