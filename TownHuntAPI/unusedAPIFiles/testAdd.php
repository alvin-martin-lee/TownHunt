
<?php
 
//creating response array
$response = array();
 
if($_SERVER['REQUEST_METHOD']=='POST'){
 
    //getting values
    $teamName = $_POST['name'];
    $memberCount = $_POST['member'];
 
 
    $response["teamName"] = $teamName;
    $response["memeber"] = $memberCount;

}
echo json_encode($response);