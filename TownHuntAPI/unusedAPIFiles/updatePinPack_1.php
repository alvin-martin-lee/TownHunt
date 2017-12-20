<?php

/* 
 * Alvin Lee
 * adds pins to the pins table in the online database
 */

$response = array();

function check_diff_multi($array1, $array2){
    $result = array();
    foreach($array1 as $key => $val) {
         if(isset($array2[$key])){
           if(is_array($val) && $array2[$key]){
               $result[$key] = $array2[$key];
           }
       } else {
           $result[$key] = $val;
       }
    }
    return $result;
} 

// Script only allows post requests
if ($_SERVER['REQUEST_METHOD'] === 'GET')
{
    // Decoding json data
    $jsonData = $_GET["data"];
    $packData = json_decode($jsonData, true);
    
    // Pack detail variable initialisation
    $packDescrip = $packData["Description"];
    $gameTime = $packData["TimeLimit"];
    $version = $packData["Version"];
    $packID = $packData["PackID"];
    $creatorID = $packData["CreatorID"];
    
    // Checks if json data was sent and received
    if(empty($jsonData))
    {
        $response["error"] = true;
        $response["message"] = "No JSON data was sent";
    }
    // Checks if json data was decoded sucessfully
    elseif (is_null($packData)) 
    {
        $response["error"] = true;
        $response["message"] = "JSON data could not be decoded";
    }
    else
    {
        // Initialises database operation object
        require_once '../includes/DBOperation.php';
        $database = new DBOperation();
        
        // Attempts to update pack details
        if ($database->alterPinPackRecord($packDescrip, $gameTime, $version, $packID, $creatorID))
        {
                // Retrieves iterable pack pin array
                $newPackPins = $packData["Pins"];
                $currentPackPins = $database->getPinsFromPack($packID);
                
                $pinsToDelete = check_diff_multi($currentPackPins, $newPackPins);
                $pinsToAdd = check_diff_multi($newPackPins, $currentPackPins);
                
                var_dump($GLOBALS);
                
                // Stores list of pins which couldn't be added to database
                $response['listOfPinsNotAdded'] = [];
                $response['listOfOrgnPinsNotDeleted'] = [];
                
                foreach ($pinsToDelete as $pinToDelete)
                {
                    // Initialises pin details
                    $pinTitle = $pinToDelete["Title"];
                    $pinHint = $pinToDelete["Hint"];
                    $pinCodeword = $pinToDelete["Codeword"];
                    $pinCoordLong = $pinToDelete["CoordLongitude"];
                    $pinCoordLat = $pinToDelete["CoordLatitude"];
                    $pinPointVal = $pinToDelete["PointValue"];
                    // Attempts to delete pins no longer in pack
                    if (!$database->deletePin($pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $packID))
                    {
                        // If not added, the pin's title is appended to 'pinsNotAddedList'
                        $response['listOfOrgnPinsNotDeleted'][] = $pinTitle;
                    }
                }
                
                // Iterates over every pin to be added
                foreach ($pinsToAdd as $pinToAdd)
                {
                    // Initialises pin details
                    $pinTitle = $pinToDelete["Title"];
                    $pinHint = $pinToDelete["Hint"];
                    $pinCodeword = $pinToDelete["Codeword"];
                    $pinCoordLong = $pinToDelete["CoordLongitude"];
                    $pinCoordLat = $pinToDelete["CoordLatitude"];
                    $pinPointVal = $pinToDelete["PointValue"];
                    
                    // Attempts to add pin to database
                    if (!$database->addPin($pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $packID))
                    {
                        // If not added, the pin's title is appended to 'pinsNotAddedList'
                        $response['listOfPinsNotAdded'][] = $pinTitle;
                    }
                }
                // If 'pinsNotAddedList' is empty all pins were sucessfully added to DB
                if (empty($response['pinsNotAddedList']) && empty($response['listOfOrgnPinsNotDeleted']))
                {
                    $response['error'] = false;
                    $response['message'] = 'Pack Updated';
                } else
                {
 //  [---------------- ERROR MESSAGES are updated ---------------------------]
                    $response['error'] = true;
                    $response['message'] = 'Could not add pin(s)';
                }
        } else
        {
            $response["error"] = true;
            $response["message"] = "Pack details could not be altered";
        }
    } 
}
else
{
    $response['error'] = true;
    $response['message'] = 'You are not authorised';
}



// Response encoded as json and sent to caller
echo json_encode($response);

