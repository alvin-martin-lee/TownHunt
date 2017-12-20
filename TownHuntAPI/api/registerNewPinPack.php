<?php

/* 
 *  registerNewPinPack.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file registers (adds to the database) new pin packs
 */

// The API/Database response is stored as an associative array
$response = array();

// Checks whether the server request method was POST
// The API file only allows POSTed data to be processed
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    // Retreives the POSTed (passed) variables
    // (htmlentities function converts all applicable "special" characters to HTML entities)
    // This removes characters that could potentially interfere with the SQL query
    $packName = htmlentities($_POST["packName"], ENT_QUOTES);
    $packDescrip = htmlentities($_POST["description"], ENT_QUOTES);
    $creatorID = htmlentities($_POST["creatorID"]);
    $packLocation = htmlentities($_POST["location"], ENT_QUOTES);
    $gameTime = htmlentities($_POST["gameTime"]);
    // Initial pack version is set to 0
    $version = 0;
    
    // Checks to see if any required variable was not passed i.e. variables are empty    
    if(empty($packName) || empty($packDescrip) || empty($creatorID) || empty($packLocation) || empty($gameTime))
    {
        // Error flag is set to true and 'missing field(s)' error message is appended to the response array
        $response["error"] = true;
        $response["message"] = "One or more fields are empty";
    }
    else 
    {
        // If all required values were passed then 
        
        // Temporarily imports the DBOperation class file
        require_once '../includes/DBOperation.php';
        // Instantiates a new DBOperation object
        $database = new DBOperation();
        
        // Checks the database to see if the pack already exists
        $doesPackExist = !empty($database->getPinPackID($packName, $creatorID, $packLocation));
        if (!$doesPackExist)
        {
            // If the pack doesn't already exists then an attempt to add the new pack to the database occurs
            if ($database->addPinPack($packName, $packDescrip, $creatorID, $packLocation, $gameTime, $version))
            {
                // New pack was registered successfully - Success response generated
                $response['error'] = false;
                $response['message'] = 'Pack added sucessfully';
                // New pack's id is retreived and appended to the response array
                $response['packData'] = $database->getPinPackID($packName, $creatorID, $packLocation);
            }
            else
            {
                // Unsuccessful registration of the pack error response is generated
                $response['error'] = true;
                $response['message'] = 'Could not add pack';
            }
        }
        else
        {
            // 'Pack Already Exists' error response is generated
            $response['error'] = true;
            $response['message'] = 'Pack Already Exists';
        }
    }
}
else
{
    // If the request method isn't POST then an error message is returned
    $response['error'] = true;
    $response['message'] = 'You are not authorised.';
}
// The Database/API response is encoded in a JSON format and echoed (sent) to the requester
echo json_encode($response);