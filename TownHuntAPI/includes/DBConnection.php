<?php

/*
 *  DBConnection.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file creates the connection to the TownHunt MySQL server
 */

// Class which allows connection to the database
class DBConnection{

    // Stores the connection to the MySQL server
    private $connection;

    // Function which creates the connection to the server
    function connectToServer()
    {
        // Information about the MySQL server (Info predefined by the host)
        $host_name  = "[HOST NAME REMOVED]";
        $database   = "[DATA BASE NAME REMOVED]"; // TownHunt database
            // Access details
        $user_name  = "[USERNAME REMOVED]";
        $password   = "[PASSWORD REMOVED]";

        // Opens the connection to the TownHunt MySQL server
        $this->connection = new mysqli($host_name, $user_name, $password, $database);

        // Checks if there was an error in establishing a connection with the server
        if(mysqli_connect_errno())
        {
            // If there was an error, it is echoed
            echo 'Failed to connect to MySQL Server'.mysqli_connect_error().'</p>';
        }

        // Returns an object that represents the connection to the MySQL server
        return $this->connection;
    }
}
