<?php

/* 
 *  getPinsFromPack.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file retreives all of the pins with a specified pack ID
 */

// Function decodes a passed string (HTML Entity) back to standard characters
function decode($stringToDecode) {
    return html_entity_decode($stringToDecode, ENT_QUOTES);
}

// The API/Database response is stored as an associative array
$response = array();

// Checks whether the server request method was POST
// The API file only allows POSTed data to be processed
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    // Retrieves the POSTed user ID
    // (htmlentities function converts all applicable "special" characters to HTML entities)
    // This removes characters that could potentially interfere with the SQL query
    $packID = htmlentities($_POST["packID"]);
    
    // Checks to see if the user ID was passed
    if(empty($packID))
    {
        // If a variable is missing then the error flag is set to true and an "missing user ID" error message
        // is appended to the response array
        $response["error"] = true;
        $response["message"] = "No Pack ID was passed";
    }
    else 
    {
        // If all required values were passed then 
        
        // Temporarily imports the DBOperation class file
        require_once '../includes/DBOperation.php';
        // Instantiates a new DBOperation object
        $database = new DBOperation();
        
        // Retreives all pins from with a specific Pack ID fromthe database 
        $pins = $database->getPinsFromPack($packID);
        
        // Error flag set to false
        $response['error'] = false;
        // Checks to see if any pins were found
        if (!empty($pins))
        {
            // If pins were found then they are decoded and appended to the reponse array
            // Pins found flag is set to true
            $response['packContainsPinsFlag'] = true;

            // Initialises the array holding the decoded pins
            $decodedPins = [];
            // Decodes each pin (and associated details) and appends it to the decoded pins array
            foreach ($pins as $pin)
            {
               $decodedPins[] = array_map("decode",$pin);
            }
            // Decoded pin array added to the response array
            $response['Pins'] = $decodedPins;
        }
        else
        {
            // Pins found flag is set to false
            $response['packContainsPinsFlag'] = false;
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
