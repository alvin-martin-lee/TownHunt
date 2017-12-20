<?php

/* 
 *  registerUser.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file registers new users and appends the details to the database
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
    $username = htmlentities($_POST["username"], ENT_QUOTES);
    $userEmail = htmlentities($_POST["userEmail"]);
    $userPassword = htmlentities($_POST["userPassword"]);
    
    // Checks to see if any required variable was not passed i.e. variables are empty
    if(empty($username) || empty($userEmail) || empty($userPassword))
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
        
        // Searches the database for record with the passed username and or email. If any records 
        // are found, then another account with the same username and or email already exists
        $userDetails = $database->getDetailsOfUser($username, $userEmail);
        
        // Checks to see fi any records were returned
        if(empty($userDetails))
        {
            // If no existing accounts were found then the new account is registered
            
            // The user's password is hashed for security reasons as the database only stores a hashed version
            // of the passwords so malicious users who gain access to the database do not know what the unhashed passwords are
            $secureUserPassword = hash("ripemd128", $userPassword);

            // Attempts to add the new user to the database
            if ($database->addUser($username, $userEmail, $secureUserPassword))
            {
                // Successful response genereated to indicate that the account was added to the database
                $response['error'] = false;
                $response['message'] = 'User added sucessfully';
            }
            else
            {
                // Unsuccessful response genereated to indicate that the account was not added to the database
                $response['error'] = true;
                $response['message'] = 'Could not add user';                
            }
        }
        else
        {
            // 'Account already exists' Error response generated
            $response['error'] = true;
            $response['message'] = 'Account already exists. Please enter a different email and or username';
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