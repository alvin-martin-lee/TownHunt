<?php

/* 
 *  addPlayedPackRecord.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file adds attempts to add a pack score record to the database
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
    $packID = htmlentities($_POST["PackID"]);
    $playerUserID = htmlentities($_POST["PlayerUserID"]);
    $score = htmlentities($_POST["Score"]);
    $gameType = htmlentities($_POST["GameType"]);
    
    // Checks to see if any required variable was not passed i.e. variables are empty
    if(empty($packID) || empty($playerUserID) || !isset($score) || empty($gameType))
    {   
        // If a variable is missing then the error flag is set to true and an "missing field" error message
        // is appended to the response array
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
        
        // Checks to see if there is already a score for the specified pack and player
            // Searches for and retrieves any score record with the passed pack id and player user id
        $userDetails = $database->getScoreRecord($packID, $playerUserID);
        // If none was found then the passed score is elegible to be added to the leaderboard
        if(empty($userDetails))
        {
            // Attempts to add the score record to the database via the DBOperation object
            if ($database->addScoreRecord($packID, $playerUserID, $score, $gameType))
            {
                // Prepares the success message if the score was added successfully
                $response['error'] = false;
                $response['message'] = 'Record Added to PlayedPack Table';
            }
            else
            {
                // Prepares the unsuccessful message if the score couldn't be added
                $response['error'] = true;
                $response['message'] = 'Could not add record';
            }
        }
        else
        {
            // If the user has already played the pack then this is conveyed in the response message
            $response['error'] = false;
            $response['message'] = 'Records for first play through of pack already exists';
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

