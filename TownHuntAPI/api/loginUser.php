<?php

/* 
 *  loginUser.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file determines if a user and associated password is found in the database
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
    $userEmail = htmlentities($_POST["userEmail"]);
    $userPassword = htmlentities($_POST["userPassword"]);
    
    // Checks to see if any required variable was not passed i.e. variables are empty
    if(empty($userEmail) || empty($userPassword))
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
    
        // The user's password is hashed for security reasons as the database only stores a hashed version
        // of the passwords so malicious users who gain access to the database do not know what the unhashed passwords are
        $secureUserPassword = hash("ripemd128", $userPassword);
        // Searches the database for the email address and the associated hashed password
        $userDetails = $database->getDetailsOfUserIncPassword($userEmail, $secureUserPassword);
        // If userDetails is not empty and a match was found then the email-password passed matched a user account
        if(!empty($userDetails))
        {
            // Login success response generated and the user details are added to the response array
            $response['error'] = false;
            $response['message'] = 'User is registered';
            $response['accountInfo'] = $userDetails;        
        }
        else
        {
            // If no record was found that means that the entered details do not match any user account
            // Login unsuccessful response generated
            $response['error'] = true;
            $response['message'] = 'Account not found. The email and or the password is incorrect';
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