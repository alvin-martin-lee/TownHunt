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
    // Retreives the POSTed (passed) variables
    // (htmlentities function converts all applicable "special" characters to HTML entities)
    // This removes characters that could potentially interfere with the SQL query
    $packID = htmlentities($_POST["packID"]);
    $userID = htmlentities($_POST["userID"]);
    // Game type variable is set to "competitive" and the number of records to retreive is set to 10
    // as in this version of the TownHunt App/API the leaderboard/account stats are only concerned 
    // with packs that were played competitively and the top ten scores
    $gameType = "competitive";
    $numRecords = 10;
    
    // Checks to see if any required variable was not passed i.e. variables are empty
    if(empty($packID) || empty($userID))
    {
        // Error flag is set to true and 'missing id(s)' error message is appended to the response array
        $response["error"] = true;
        $response["message"] = "No User ID  and or Pack ID passed";
    }
    else 
    {
        // If all required values were passed then 
        
        // Temporarily imports the DBOperation class file
        require_once '../includes/DBOperation.php';
        // Instantiates a new DBOperation object
        $database = new DBOperation();
        
        // The top 10 scores records and their details are attempted to be retrieved from the database
        $topScoreRecords = $database->getTopPackScoreRecords($packID, $gameType, $numRecords);
        // Checks if any score were found
        if (!empty($topScoreRecords))
        {
            // If scores were found it means the pack has been played competitively
            // Error flag set to false by default
            $response['error'] = false;
            // The score records are appended to the response array
            $response['topScoreRecords'] = $topScoreRecords;
            
            // The total number of players who have played the pack is retreived
            $numOfPlayersOfPack = $database->getTotalNumOfPlayersOfPlayedPack($packID, $gameType)["COUNT(DISTINCT `Player_UserID`)"];
            // Checks to see if a value for $numOfPlayersOfPack was retreived
            if (isset($numOfPlayersOfPack))
            {
                // If a value was set then the number of players is appended to the array
                $response['numOfPlayersOfPack'] = $numOfPlayersOfPack;
            }
            else
            {
                // Otherwise an the error flag is set to true and an error message is generated
                $response['error'] = true;
                $response['message'][] = 'Could not get the number of players who have played the pack';
            }

            // Retreives the average competitive score for the pack
            $averageScore = $database->getAverageScoreOfPlayedPack($packID, $gameType)["AVG(`Score`)"];
            // Checks to see if a value for $averageScore was retreived
            if (isset($averageScore))
            {
                // If a value was set then the average score (rounded to 1 decimal place) is appended to the array
                 $response['averageScore'] = round($averageScore, 1);
            }
            else
            {
                // Otherwise an the error flag is set to true and an error message is generated
                $response['error'] = true;
                $response['message'][] = 'Could not get average score of everyone who has played the pack';
            }
            
            // Retreives the score and ranking of the specified (logged in) user
            $userScoreAndRank = $database->getUserPackScoreAndRank($packID, $gameType, $userID);
            $score = $userScoreAndRank["Score"];
            $rank = $userScoreAndRank["Rank"];
            // Checks to see if values were set for the user's score and ranking
            if (isset($score) && isset($rank))
            {
                // If a values were set then they are appended to the array
                $response['userScore'] = $score;
                $response['userRank'] = $rank;
                
            }
            else
            {
                // User score and rank is set to N/A as the user hasn't played the pack competitively
                $response['userScore'] = "N/A ";
                $response['userRank'] = "N/A";
                $response['message'][] = 'Could not get user score and rank';
            }
        }
        else
        {
            // No user has played the pack competitively
            // Error message is generated
            $response['error'] = true;
            $response['message'][] = "Pack Hasn't Been Played Competitively";
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