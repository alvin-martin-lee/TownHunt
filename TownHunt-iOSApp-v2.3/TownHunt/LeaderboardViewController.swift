//
//  LeaderboardViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the leaderboard view

import UIKit // UIKit constructs and manages the app's UI

// Class acts as the logic behind the leaderboard
class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet var leaderboardTable: UITableView! // The table view containing the leaderboard info
    @IBOutlet weak var packLeaderboardHeaderLabel: UIButton! // Info bar below the nav bar
    @IBOutlet weak var userPositionLabel: UILabel! // Logged in user's position in the leaderboard
    @IBOutlet weak var userPointsScoreLabel: UILabel! // Logged in user's score in the leaderboard
    @IBOutlet weak var averagePointsScoredLabel: UILabel! // Average score of all the players who have plaeyd the pack
    @IBOutlet weak var numberOfPlayersLabel: UILabel! // Total number of plays who have played the pack
    
    // Initialises attributes which will hold details about the selected pack, the associated leaderboard and the user
    public var selectedPackKey = "" // Pack name-location key
    public var packCreatorID = ""
    private var packID = ""
    private var userID = ""
    private var leaderboardRecords = [[String:String]]()
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Sets up the leaderboard table
        leaderboardTable.delegate = self // Gives this current class the ability to control the table UI element
        leaderboardTable.dataSource = self // The data source of the table is set as this current class
        getUserID()
        getPackID()
        getLeaderboardData()
    }

    // Retrives the logged in user's id
    private func getUserID(){
        userID = UserDefaults.standard.string(forKey: "UserID")!
    }
    
    // Retrieves the pack id of the selected pack
    private func getPackID(){
        // Checks that the selectedPackKey and packCreatorID is not empty otherwise an error message is displayed
        if !(self.selectedPackKey.isEmpty || self.packCreatorID.isEmpty){
            let userPackDictName = "UserID-\(packCreatorID)-Packs"
            let defaults = UserDefaults.standard
            if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
                // Opens file and retrieves the pack data and hence the pack id
                let filename = dictOfPacksOnPhone[selectedPackKey] as! String
                let packData = PinPackMapViewController().loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: packCreatorID)
                packID =  packData["PackID"] as! String
            } else{ // Error message displayed
                displayAlertMessage(alertTitle: "Error", alertMessage: "Data Couldn't be loaded")
            }
        } else{ // Error message displayed
            displayAlertMessage(alertTitle: "Error", alertMessage: "Selected pack data not passed")
        }
    }
    
    // Prepares the leaderboard data to be displayed in the UI
    private func setLeaderboardData(data: [String:Any]){
        // Sets the leaderboard records to the top 10 scores retreived from the database
        leaderboardRecords = data["topScoreRecords"] as! [[String : String]]
        // Refreshes the leaderboard tables displayed to the user
        leaderboardTable.reloadData()
        
        // Sets up pack info and the info about the logged in user's ranking/score
        let userRank = data["userRank"]! as! String
        let userScore = data["userScore"]! as! String
        let averageScore = String(describing: data["averageScore"]!)
        let numOfPackPlayers = data["numOfPlayersOfPack"]! as! String
        // Updates the UI display
        setNonTableLabels(userRank: userRank, userScore: userScore, averageScore: averageScore, numPlayers: numOfPackPlayers)
    }
    
    // Updates the UI labels displayed to the user
    private func setNonTableLabels(userRank: String, userScore: String, averageScore: String, numPlayers: String){
        packLeaderboardHeaderLabel.setTitle("\(selectedPackKey): Top 10", for: UIControlState())
        userPositionLabel.text = userRank
        userPointsScoreLabel.text = "\(userScore)pts"
        averagePointsScoredLabel.text = "\(averageScore)pts"
        numberOfPlayersLabel.text = numPlayers
    }
    
    // Retrieves leaderboard data from the database
    private func getLeaderboardData(){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // Sets up string to be posted to the database api
            let postData = "packID=\(packID)&userID=\(userID)"
            
            // The post string is posted to the online database API via the DatabaseInteraction class on the background thread
            // The "getPackLeaderboardInfo.php" API retrieves all of the leaderboard information about a pack from the online database
            let responseJSON = dbInteraction.postToDatabase(apiName: "getPackLeaderboardInfo.php", postData: postData){ (dbResponse: NSDictionary) in
                
                // Retrieves the database response
                let isError = dbResponse["error"]! as! Bool
                var errorMessage = ""
                
                // Prepares the error message if there were errors
                if isError{
                    for message in dbResponse["message"] as! [String]{
                        errorMessage = errorMessage + "\n" + message
                    }
                }
                // Returns the execution flow to the main thread
                DispatchQueue.main.async(execute: {
                    if isError{ // If there is an error it is displayed to the user and the view is dismissed
                        let alertCon = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                            self.dismiss(animated: true, completion: nil)}))
                        self.present(alertCon, animated: true, completion: nil)
                    } else{ // If no errors then the data received is processed and displayed to the user
                        self.setLeaderboardData(data: dbResponse as! Dictionary<String, Any>)
                    }
                })
            }
        } else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the getLeaderboardData function until internet connectivity is restored
                self.getLeaderboardData()
            }))
            self.present(alertCon, animated: true, completion: nil)
        }

    }
    
    // TableView method that sets the number of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in the table is the same as the number of records in the leaderboardRecords array
        return leaderboardRecords.count
    }
    
    // TableView method which defines what to display in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Returns a reusable table-view cell object based on the prototype cell defined in the UI storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardRecordCell", for: indexPath) as! LeaderboardRecordTableViewCell
        
        // Sets up the label in the cell with information about each record
        let record = leaderboardRecords[indexPath.row]
        cell.positionLabel?.text = String(indexPath.row + 1)
        cell.pointsScoreLabel?.text = "\(record["Score"]!)pts"
        cell.playerNameLabel?.text = record["Username"]!
        
        return cell
    }
    
    // Connects the back buton in the navigation bar to the code
    // - Dismisses the view when the back button is tapped
    @IBAction func backNavButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Connects the help button in the navigation bar to the code
    // - Displays an alert informing the user about the leaderboard
    @IBAction func helpButtonTapped(_ sender: Any) {
        displayAlertMessage(alertTitle: "Help: About the Leaderboard", alertMessage: "The top ten competitive scores of the pack are displayed in the table. At the bottom you can see some statistics about the pack scores - like the average score and the number of people who have played the pack competitively.\n\nIf you have played the pack competitively then your ranking and score also appears at the bottom.\n\nNB If two players score the same score, the user who joined TownHunt first will be ranked higher")
    }
}

