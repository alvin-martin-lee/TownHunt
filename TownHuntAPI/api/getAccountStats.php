<?php

/* 
 *  getAccountStats.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file attempts to add a pack score record to the database
 */

// The API/Database response is stored as an associative array
$response = array();

// Checks whether the server request method was POST
// The API file only allows POSTed data to be processed
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    // Retrieves the POSTed user ID
    // (htmlentities function converts all applicable "special" characters to HTML entities)
    // This removes characters that could potentially interfere with the SQL query
    $userID = htmlentities($_POST["userID"]);
    // Game type variable is set to "competitive" as in this version of the TownHunt App/API
    // The leaderboard/account stats are only concerned with packs that were played competitively
    $gameType = "competitive";
    
    // Checks to see if the user ID was passed
    if(empty($userID))
    {
        // If a variable is missing then the error flag is set to true and an "missing user ID" error message
        // is appended to the response array
        $response["error"] = true;
        $response["message"] = "No User ID passed";
    }
    else 
    {
        // If all required values were passed then 
        
        // Temporarily imports the DBOperation class file
        require_once '../includes/DBOperation.php';
        // Instantiates a new DBOperation object
        $database = new DBOperation();
        
        // The total number of packs created by the specified user is retrieved from the database
        $totNumCreated = $database->getTotalNumPacksCreated($userID);
        // Checks to see if a value has been set for $totNumCreated and therefore if the database query was successful
        if (isset($totNumCreated))
        {
            // If a value has been set, then the error flag is set to false and the total number
            // of packs created by the user is added to the response array
            $response['error'] = false;
            $response['totalNumPacksCreated'] = $totNumCreated["COUNT(`Creator_UserID`)"];
        }
        else
        {
            // Error flag is set to true and an error message is appended to the response message array
            $response['error'] = true;
            $response['message'][] = 'Could not retrieve number of packs created';
        }
        // The total number of packs played by the specified user is retrieved from the database
        $totNumPlayed = $database->getTotalNumPacksPlayed($userID)["COUNT(`Player_UserID`)"];
        // Checks to see if a value has been set for $totNumPlayed and therefore if the database query was successful
        if (isset($totNumPlayed))
        {
            // If a value has been set, then the error flag is set to false if there wasn't an error in an earlier query
            // and the total number of packs played by the user is added to the response array
            $response['error'] = false || $response['error'];
            $response['totalNumPacksPlayed'] = $totNumPlayed;
        }
        else
        {
            // Error flag is set to true and an error message is appended to the response message array
            $response['error'] = true;
            $response['message'][] = 'Could not retrieve number of packs played';
        }
        
        // The total number of points scored competitively by the specified user is retrieved from the database
        $totNumCompPoints = $database->getTotalNumPoints($userID, $gameType)["SUM(`Score`)"];
        // The query either results in nul (if the user hasn't played any packs yet) or the number of points 
        // scored therefore the error is set to false if there wasn't an error in an earlier query
        $response['error'] = false || $response['error'];
        // Checks if the value retrieved was null 
        if (is_null($totNumCompPoints))
        {
            // If so, the total number of points is set to 0 and appended to the array
            $response['totalNumCompPoints'] = "0";
        } 
        else
        {
            // the total number of points is set by the value retrieved and appended to the array
            $response['totalNumCompPoints'] = $totNumCompPoints;
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
