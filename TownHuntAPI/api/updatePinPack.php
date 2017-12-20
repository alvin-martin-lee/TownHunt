<?php

/* 
 *  getPackLeaderboardInfo.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file retreives the leaderboard information for a specific pack and the 
 *  performance of a specific player for the pack
 */

// The API/Database response is stored as an associative array
$response = array();

// Checks whether the server request method was POST
// The API file only allows POSTed data to be processed
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    // Retreives the POSTed data (JSON string)
    $jsonData = $_POST["data"];
    // Decodes the passed JSON string
    $packData = json_decode($jsonData);
    
    // Checks if json data was sent and received
    if(empty($jsonData))
    {
        $response["error"] = true;
        $response["message"] = "No JSON data was sent";
    }
    // Checks if JSON data was decoded sucessfully
    elseif (is_null($packData)) 
    {
        // If $packData is null then the JSON string wasn't decoded
        // "JSON couldn't be decoded" error response is generated
        $response["error"] = true;
        $response["message"] = "JSON data could not be decoded";
    }
    else
    {
        // Pack details are retreived from the passed data
        $packDescrip = $packData->{"Description"};
        $gameTime = $packData->{"TimeLimit"};
        $version = $packData->{"Version"};
        $packID = $packData->{"PackID"};
        $creatorID = $packData->{"CreatorID"};
        
        // Temporarily imports the DBOperation class file
        require_once '../includes/DBOperation.php';
        // Instantiates a new DBOperation object
        $database = new DBOperation();
        
        // Attempts to update pack details
        if ($database->alterPinPackRecord($packDescrip, $gameTime, $version, $packID, $creatorID))
        {
            // Attempts to delete old existing pack pins
            if ($database->deleteAllPinsFromPack($packID))
            {
                // Retrieves iterable pack pin array
                $packPins = $packData->{"Pins"};
                // Stores list of pins which couldn't be added to database
                $response['pinsNotAddedList'] = [];
                
                // Iterates over every pin
                foreach ($packPins as $pin)
                {
                    // Initialises pin details
                    $pinTitle = $pin->{"Title"};
                    $pinHint = $pin->{"Hint"};
                    $pinCodeword = $pin->{"Codeword"};
                    $pinCoordLong = $pin->{"CoordLongitude"};
                    $pinCoordLat = $pin->{"CoordLatitude"};
                    $pinPointVal = $pin->{"PointValue"};
                    
                    // Attempts to add pin to database
                    if (!$database->addPin($pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $packID))
                    {
                        // If not added, the pin's title is appended to 'pinsNotAddedList'
                        $response['pinsNotAddedList'][] = $pinTitle;
                    }
                }
                // If 'pinsNotAddedList' is empty all pins were sucessfully added to DB
                if (empty($response['pinsNotAddedList']))
                {
                    // Successfully updated pack response generated
                    $response['error'] = false;
                    $response['message'] = 'Pack Updated';
                } 
                else
                {
                    // Error response generated
                    $response['error'] = true;
                    $response['message'] = 'Could not add pin(s)';
                }
            }
            else
            {
                // Error response generated
                $response["error"] = true;
                $response["message"] = "Old pin data could not be deleted";
            }
        } 
        else
        {
            // Error response generated
            $response["error"] = true;
            $response["message"] = "Pack details could not be altered";
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