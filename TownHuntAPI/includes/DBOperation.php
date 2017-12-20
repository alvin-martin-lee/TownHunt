<?php

/* 
 *  DBOperation.php
 *  TownHunt API
 *
 *  Created by Alvin Lee.
 *  Copyright © 2017 Alvin Lee. All rights reserved.
 *
 *  This file defines the database operations (SQL Queries)
 */

// Class contains all of the database operations (SQL Queries)
class DBOperation
{
    // Stores the connection to the MySQL server
    private $connection;
    
    // 
    function __construct() {
        // Temporarily imports the DBConnection class
        require_once dirname(__FILE__) . '/DBConnection.php';
        // Creates a database connection
        $database = new DBConnection();
        $this->connection = $database->connectToServer();
    }
    
    
    private function execQueryFetchSingleRow($query)
    {
        $result = array();
        $stmt = $this->connection->query($query);
        if ($stmt != null && (mysqli_num_fields($stmt)>=1))
        {
            $row = $stmt->fetch_array(MYSQLI_ASSOC);
            if (!empty($row))
            {
                $result = $row;
            }
            $stmt->close();
        }
        return $result;
    }
    
    public function execQueryFetchMultiRows($query)
    {
        $result = array();
        $stmt = $this->connection->query($query);
        if ($stmt != null && (mysqli_num_fields($stmt)>=1))
        {
            $result = mysqli_fetch_all($stmt, MYSQLI_ASSOC);
            $stmt->close();
        }
        return $result;
    }
    
    //[---------------- User Account Queries -----------------------------------]
        
    public function getDetailsOfUser($username, $userEmail)
    {
        $query = "SELECT * FROM `db648556307`.`Users` WHERE `Username` = '".$username."' OR `Email` = '".$userEmail."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getDetailsOfUserIncPassword($userEmail, $userPassword)
    {
        $query = "SELECT `UserID`, `Username`, `Email` FROM `db648556307`.`Users` WHERE `Email` = '".$userEmail."' AND `Password` = '".$userPassword."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function addUser($username, $userEmail, $userPassword)
    {
        $stmt = $this->connection->prepare("INSERT INTO `db648556307`.`Users` (`UserID`, `Username`, `Email`, `Password`) VALUES (NULL, ?, ?, ?);");
        $stmt->bind_param("sss", $username, $userEmail, $userPassword);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    }
    
    //[---------------Pin Pack Queries------------------------------------]
    
    public function addPin($title, $hint, $codeword, $coordLong, $coordLat, $pointVal, $packID)
    {
        $stmt = $this->connection->prepare("INSERT INTO `db648556307`.`Pins` (`PinID`, `Title`, `Hint`, `Codeword`, `CoordLongitude`, `CoordLatitude`, `PointValue`, `PackID`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssddii", $title, $hint, $codeword, $coordLong, $coordLat, $pointVal, $packID);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    }
    
    public function addPinPack($packName, $packDescrip, $creatorID, $packLocation, $gameTime, $version)
    {
        $stmt = $this->connection->prepare("INSERT INTO `db648556307`.`PinPacks` (`PackID`, `PackName`, `PackDescription`, `Creator_UserID`, `Location`, `GameTime`, `Version`) VALUES (NULL, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssisii", $packName, $packDescrip, $creatorID, $packLocation, $gameTime, $version);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    }
    
    public function getPinPackID($packName, $creatorID, $packLocation)
    {
        $query = "SELECT `PackID` FROM `db648556307`.`PinPacks` WHERE `PackName` = '".$packName."' AND `Creator_UserID` = '".$creatorID."' AND `Location` = '".$packLocation."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getPinsFromPack($packID)
    {
        
        $query = "SELECT `Title`, `Hint`, `Codeword`, `CoordLongitude`, `CoordLatitude`, `PointValue` FROM `db648556307`.`Pins` WHERE `PackID` = '".$packID."'";
        return $this->execQueryFetchMultiRows($query);
    }

    public function alterPinPackRecord($packDescrip, $gameTime, $version, $packID, $creatorID)
    {
        $stmt = $this->connection->prepare("UPDATE `db648556307`.`PinPacks` SET `PackDescription` = ?, `GameTime` = ?, `Version` = ? WHERE `PinPacks`.`PackID` = ? AND `PinPacks`.`Creator_UserID` = ?;");
        $stmt->bind_param("siiii", $packDescrip, $gameTime, $version, $packID, $creatorID);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    } 
    
    public function deletePin($pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $packID)
    {
        $stmt = $this->connection->prepare("DELETE FROM `db648556307`.`Pins` WHERE `Title` = ? AND `Hint` = ? AND `Codeword` = ? AND `CoordLongitude` = ? AND `CoordLatitude` = ? AND `PointValue` = ? AND `PackID` = ?;");
        $stmt->bind_param("sssddii", $pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $packID);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    } 
    
    public function deleteAllPinsFromPack($packID)
    {
        $stmt = $this->connection->prepare("DELETE FROM `db648556307`.`Pins` WHERE `Pins`.`PackID` = ?;");
        $stmt->bind_param("i", $packID);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    } 
    
    //[------------------Pack Table Search---------------------------------]
    
    public function getPackDetailsFromSearch($usernameFragment, $packNameFragment, $locationFragment)
    {
        $query = "
            SELECT pinPackTable.`PackID`, pinPackTable.`PackName`, pinPackTable.`PackDescription` AS Description, pinPackTable.`Location`, pinPackTable.`GameTime` AS TimeLimit, pinPackTable.`Version`, possibleCreatorTable.`Username` as CreatorUsername, possibleCreatorTable.`UserID` AS CreatorID
            FROM `db648556307`.`PinPacks` AS pinPackTable,  
                (SELECT `UserID`, `Username`
                FROM `db648556307`.`Users` 
                WHERE `Username` LIKE '%".$usernameFragment."%') AS possibleCreatorTable
                WHERE pinPackTable.`PackName` LIKE '%".$packNameFragment."%' AND pinPackTable.`Location` LIKE '%".$locationFragment."%' AND pinPackTable.`Creator_UserID` =  possibleCreatorTable.`UserID`
            ORDER BY pinPackTable.`PackName` DESC";
        return $this->execQueryFetchMultiRows($query);
    }
    
    //[---------------Leaderboard Queries------------------------------------]

    public function getScoreRecord($packID, $playerUserID){
        $query = "SELECT * FROM `db648556307`.`PlayedPacks` WHERE `PackID` = '".$packID."' AND `Player_UserID` = '".$playerUserID."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getTotalNumPacksPlayed($userID)
    {   
        $query = "SELECT COUNT(`Player_UserID`) FROM `db648556307`.`PlayedPacks` WHERE `Player_UserID` = '".$userID."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getTotalNumPacksCreated($userID)
    {
        $query = "SELECT COUNT(`Creator_UserID`) FROM `db648556307`.`PinPacks` WHERE `Creator_UserID` = '".$userID."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getTotalNumPoints($userID, $gameType)
    {
        $query = "SELECT SUM(`Score`) FROM `db648556307`.`PlayedPacks` WHERE `Player_UserID` = '".$userID."' AND `GameType` = '".$gameType."'";
        return $this->execQueryFetchSingleRow($query);

    }
    
    public function getTotalNumOfPlayersOfPlayedPack($packID, $gameType)
    {
        $query = "SELECT COUNT(DISTINCT `Player_UserID`) FROM `db648556307`.`PlayedPacks` WHERE `PackID` = ".$packID." AND `GameType` = '".$gameType."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getAverageScoreOfPlayedPack($packID, $gameType)
    {
        $query = "SELECT AVG(`Score`) FROM `db648556307`.`PlayedPacks` WHERE `PackID` = ".$packID." AND `GameType` = '".$gameType."'";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getUserPackScoreAndRank($packID, $gameType, $userID)
    {
        $query = "
            SELECT `Score`, Rank
            FROM (SELECT `Player_UserID`, `Score`, (@rn := @rn + 1) as Rank
                  FROM `db648556307`.`PlayedPacks` CROSS JOIN
                  (SELECT @rn := 0) CONST
                  WHERE `PackID` = ".$packID." AND `GameType` = '".$gameType."'
                  ORDER BY `Score` DESC
                  ) AS temp
            WHERE `Player_UserID` = ".$userID."";
        return $this->execQueryFetchSingleRow($query);
    }
    
    public function getTopPackScoreRecords($packID, $gameType, $numRecords)
    {
        $query = "
            SELECT playedPacksTable.`Score`, userTable.`Username`
            FROM `db648556307`.`PlayedPacks` AS playedPacksTable,  `db648556307`.`Users` AS userTable
            WHERE playedPacksTable.`PackID` = ".$packID." AND playedPacksTable.`Player_UserID` = userTable.`UserID` AND playedPacksTable.`GameType` = '".$gameType."'
            ORDER BY playedPacksTable.`Score` DESC LIMIT ".$numRecords."";
        return $this->execQueryFetchMultiRows($query);
    }
    
    public function addScoreRecord($packID, $playerUserID, $score, $gameType){
        $stmt = $this->connection->prepare("INSERT INTO `db648556307`.`PlayedPacks` (`PackID`, `Player_UserID`, `Score`, `GameType`) VALUES (?, ?, ?, ?);");
        $stmt->bind_param("iiis", $packID, $playerUserID, $score, $gameType);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    }
    
}
