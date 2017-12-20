<?php

/* 
 *  packSearch.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file retreives details of packs found from searching the database with 
 *  the passed search critereon
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
    // Retreives the POSTed (passed) variables
    // (htmlentities function converts all applicable "special" characters to HTML entities)
    // This removes characters that could potentially interfere with the SQL query
    $usernameFragment = htmlentities($_POST["usernameFragment"], ENT_QUOTES);
    $packNameFragment = htmlentities($_POST["packNameFragment"], ENT_QUOTES);
    $locationFragment = htmlentities($_POST["locationFragment"], ENT_QUOTES);
    
    // Temporarily imports the DBOperation class file
    require_once '../includes/DBOperation.php';
    // Instantiates a new DBOperation object
    $database = new DBOperation();
        
    // Searches the detabase for packs with details similar to the critereon (fragments) passed
    $searchResult = $database->getPackDetailsFromSearch($usernameFragment, $packNameFragment, $locationFragment);
    // Checks if search results (packs) were returned
    if (!empty($searchResult))
    {
        // Packs Were Found
        
        // Error flag is set to false
        $response['error'] = false;

        // Initialises the decoded pack detail array
        $decodedSearchResult = [];
        // Iterates through the search results and decodes all of the pack details
        foreach ($searchResult as $pack)
        {
           // Decoded pack results are appended to the decoded pack details array
           $decodedSearchResult[] = array_map("decode",$pack);
        }
        // Decoded pack details array is appended to the response array
        $response['searchResult'] = $decodedSearchResult;
    }
    else
    {
        // 'No Matches Found' error generated
        $response['error'] = true;
        $response['message'] = 'Could not find any matches in the database';
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