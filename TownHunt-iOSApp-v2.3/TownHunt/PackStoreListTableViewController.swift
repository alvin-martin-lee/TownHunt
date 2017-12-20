//
//  PackListTableViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic behind the pack store list table screen

import UIKit // UIKit constructs and manages the app's UI

// Class controls the pack store list table view
class PackStoreListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var infoBarButton: UIButton! // Info bar just below the orange navigation bar
    @IBOutlet var packListTable: UITableView! // The table itself
    
    // This flag determines if the local packs from the phone should be loaded
    public var loadLocalPacksFlag = false
    // Attribute stores the search string to post
    public var searchDataToPost = ""
    // The data source of the table - containing a list of packs and their respective details
    public var packListTableData = [[String: String]]()
    // Holds the selected pack's details
    public var selectedPackDetails = [String:Any]()
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()

        // Sets up the leaderboard table
        packListTable.delegate = self // Gives this current class the ability to control the table UI element
        packListTable.dataSource = self // The data source of the table is set as this current class
        
        // Checks to see if there is a search string
        if !searchDataToPost.isEmpty{
            self.navigationItem.title = "Store Search Results" // Changes title
            searchDatabaseForPacks() // Sends the search string to the online database API
        // Checks if the loadLocalPacks flag is true
        } else if loadLocalPacksFlag == true{
            self.navigationItem.title = "List Of Local Packs" // Changes title
            loadLocalPacksIntoView() // Retrieves all of the pack on the phone
        }
    }
    
    // [-------------------------- Table Mechanics ---------------------------------------]
    
    // Sorts the pack list array and refreshed the table
    private func loadDataIntoTable(data: [[String: String]]){
        // Sorts the pack list in alphabetical order
        packListTableData = data.sorted{ ($0["PackName"])!.lowercased() < ($1["PackName"])!.lowercased() }
        packListTable.reloadData() // Refreshes the table
    }
    
    // TableView method that sets the number of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in the table is the same as the number of packs in the packListTableData array
        return packListTableData.count
    }
    
    // TableView method which defines what to display in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Returns a reusable table-view cell object based on the prototype cell defined in the UI storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "packInfoCell", for: indexPath) as! PackStoreListTableViewCell
        
        // Sets up the label in the cell with information about each pack
        let pack = packListTableData[indexPath.row]
        cell.packNameLabel?.text = pack["PackName"]!
        cell.locationLabel?.text = "Location: \(pack["Location"]!)"
        cell.descriptionLabel?.text = pack["Description"]!
        // Creator username is optional as it is not stored for local packs
        if let creatorUsername = pack["CreatorUsername"]{
            cell.creatorNameLabel?.text = "Made By: \(creatorUsername)"
        } else{
            cell.creatorNameLabel?.text = ""
        }
        cell.gameTimeLabel?.text = "Time Cap:\(pack["TimeLimit"]!)mins"
        
        return cell
    }
    
    // TableView method which is called when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Retrieves the selected row's pack details
        selectedPackDetails = packListTableData[indexPath.row]
        // Checks the load local packs flag to determine what options to present the user with
        if loadLocalPacksFlag == true{ // Local packs are therefore loaded into the table
            
            // Alert is presented to the user with the full pack details of the selected pack, there is an option to delete the pack from the phone
            let alertCon = UIAlertController(title: selectedPackDetails["PackName"]! as? String, message: "Location: \(selectedPackDetails["Location"]!)\n\nAbout: \(selectedPackDetails["Description"]!)!\n\nTime Cap: \(selectedPackDetails["TimeLimit"]!) mins\n\nVersion: \(selectedPackDetails["Version"]!)", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                // If the user taps delete then the pack details are sent to the deleteSelectedLocalPack function
                self.deleteSelectedLocalPack(packName: self.selectedPackDetails["PackName"]! as! String, packLocation: self.selectedPackDetails["Location"]! as! String, creatorID: self.selectedPackDetails["CreatorID"]! as! String)
            }))
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertCon, animated: true, completion: nil)
        
        } else{ // The packs loaded in the table are search results 
            // Alert is presented to the user with the full pack details of the selected pack, there is an option to download the pack to the phone
            let alertCon = UIAlertController(title: selectedPackDetails["PackName"]! as? String, message: "Made By: \(selectedPackDetails["CreatorUsername"]!)\n\nLocation: \(selectedPackDetails["Location"]!)\n\nAbout: \(selectedPackDetails["Description"]!)!\n\nTime Cap: \(selectedPackDetails["TimeLimit"]!)mins\n\nVersion: \(selectedPackDetails["Version"]!)", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Download", style: .destructive, handler: {action in
                // If the user taps download then the pack id is sent to the downloadPackFromDB function
                self.downloadPackFromDB(packID: self.selectedPackDetails["PackID"]! as! String)}))
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    // [-------------------------------- Local Storage Mechanics --------------------------------------------]
    
    // Generates (and returns) the pack file name and subdirectory
    private func getFileNameAndSubDirString(packName: String, creatorID: String) -> [String:String]{
        let fileName = (packName).replacingOccurrences(of: " ", with: "_")
        let subDirect = "UserID-\(creatorID)-Packs"
        return ["fileName":fileName, "subDirectory": subDirect]
    }
    
    // Retrieves local pack data
    private func loadLocalPacksIntoView(){
        packListTableData = [[String: String]]() // Clears pack list table data
        let defaults = UserDefaults.standard
        // Retrieves the list of user ids whose packs are found in local storage
        if let listOfUsersOnPhone = defaults.array(forKey: "listOfLocalUserIDs"){
            // Iterates over every id and retrieves all packs on the phone
            for userID in listOfUsersOnPhone as! [String]{
                let userPackSubDirectory = "UserID-\(userID)-Packs"
                // Checks if the user pack dictionary exists
                if let displayNameFilenamePairs = defaults.dictionary(forKey: userPackSubDirectory) {
                    // Appends all pack names and their creator user id to the allPacksDict
                    for filename in Array(displayNameFilenamePairs.values){
                        // Instantiates an instance of the LocalStorageHandler class
                        let storageHandler = LocalStorageHandler(fileName: filename as! String, subDirectory: userPackSubDirectory, directory: .documentDirectory)
                        // Retrieves the pack info
                        var packOnPhone = storageHandler.retrieveJSONData() as! [String:Any]
                        packOnPhone.removeValue(forKey: "Pins") // Removes the pins as we are only concerned with the pack details right now
                        packListTableData.append(packOnPhone as! [String:String]) // Appends to the table data source
                    }
                }
                
            }
        } // Loads the data into the UI table
        loadDataIntoTable(data: packListTableData)
        // Checks if any packs were found
        if packListTableData.isEmpty{ // No packs were found
            updateInfoBarMessage(message: "0 Results Found")
            // Message is displayed to the user
            let alertCon = UIAlertController(title: "Error", message: "No packs found on the device. Search for and download some packs!", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                // Pack store table view is dismissed
                self.dismiss(animated: true, completion: nil) }))
            self.present(alertCon, animated: true, completion: nil)
        }else{ // Packs were found
            // Number of results is generated and displayed
            updateInfoBarMessage(message: "\(packListTableData.count) Result(s) Found")
        }
    }
    
    // Prepares the pack data to be saved as a json file
    private func preparePackToSave(pins: [[String:String]], didContainPins: Bool){
        // Initiates JSON array
        var jsonToWrite = selectedPackDetails
        jsonToWrite.removeValue(forKey: "CreatorUsername")
        
        // Checks if there are pins in the pack
        if didContainPins{
            jsonToWrite["Pins"] = pins
        } else{ // Otherwise an empty array will be stored
            jsonToWrite["Pins"] = []
        }
        
        // Converts pack details into the correct filename and subdirectory
        let filePathDetails = getFileNameAndSubDirString(packName: jsonToWrite["PackName"] as! String, creatorID: jsonToWrite["CreatorID"] as! String)
        
        // Instantiates a LocalStorageHandler instance
        let storageHandler = LocalStorageHandler(fileName: filePathDetails["fileName"]!, subDirectory: filePathDetails["subDirectory"]!, directory: .documentDirectory)
        
        // Checks if the pack has already been downloaded and a file for the pack already exists
        if storageHandler.getDoesFileExist() == true{
            // User is alerted about the file's existence and asked if s/he wants to override it
            let alertCon = UIAlertController(title: "A Version Of The Pack Exists On The Phone", message: "Do you want to overwrite the version on the phone with the downloaded pack?", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertCon.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
                // If yes is selected then the file overrides the existing file
                self.savePackToLocalStorage(storageHandler: storageHandler, dataToWrite: jsonToWrite as NSDictionary)}))
            self.present(alertCon, animated: true, completion: nil)
        } else{
            //Stores the pack details (JSON file) to local storage via the LocalStorageHandler class
            self.savePackToLocalStorage(storageHandler: storageHandler, dataToWrite: jsonToWrite as NSDictionary)
        }

    }
    
    // Saves packs (in JSON format) to the local storage
    private func savePackToLocalStorage(storageHandler: LocalStorageHandler, dataToWrite: NSDictionary){
        // If there is an error with saving the json file, the user is presented with an alert with details of the error
        if storageHandler.addNewPackToPhone(packData: dataToWrite as NSDictionary){
            displayAlertMessage(alertTitle: "Success", alertMessage: "\(dataToWrite["PackName"]! as! String) Saved To Phone")
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "\(dataToWrite["PackName"]! as! String) Wasn't 'Saved To Phone")
        }
    }
    
    // Deletes the passed pack file from the local storage
    private func deleteSelectedLocalPack(packName: String, packLocation: String, creatorID: String){
        // Converts pack details into the correct filename and subdirectory
        let filePathDetails = getFileNameAndSubDirString(packName: packName, creatorID: creatorID)
        // Instantiates a LocalStorageHandler instance
        let storageHandler = LocalStorageHandler(fileName: filePathDetails["fileName"]!, subDirectory: filePathDetails["subDirectory"]!, directory: .documentDirectory)
        // Attempts to delete the file
        if storageHandler.deleteFile(packName: packName, packLocation: packLocation, creatorID: creatorID) {
            // User is alerted about the successful deletion
            displayAlertMessage(alertTitle: "Success", alertMessage: "\(packName) was deleted from the phone")
            loadLocalPacksIntoView() // Local pack list table is reloaded
        } else{
            // User is alerted about the unsuccessful deletion
            displayAlertMessage(alertTitle: "Error", alertMessage: "\(packName) could not be deleted from the phone")
        }
    }
    
    //[ -------------------------- Online Database Mechanics -----------------------------]
    
    // Sets up the database interaction to download a pack from the online database
    private func downloadPackFromDB(packID: String){
        // The "getPinsFromPack.php" API returns all of the pins found for a certain pack id from the online database
        retrieveDataFromDatabase(api: "getPinsFromPack.php", postData: "packID=\(packID)")
    }
    
    // Sets up the database interaction to search for packs from the online database
    private func searchDatabaseForPacks(){
        // The "packSearch.php" API returns a list of pack details that is similar to the search fragments input by the user
        retrieveDataFromDatabase(api: "packSearch.php", postData: searchDataToPost)
    }
    
    // Retrieves data from the online database
    private func retrieveDataFromDatabase(api: String, postData: String){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // A post string is posted to the online database API via the DatabaseInteraction class on the background thread
            let responseJSON = dbInteraction.postToDatabase(apiName: api, postData: postData){ (dbResponse: NSDictionary) in
                // Database response is interpreted
                
                // Default error variables initialised
                let isError = dbResponse["error"]! as! Bool
                var errorMessage = ""
                
                // Checks if there is an error, if there is then the error message is retrieved
                if isError{
                    errorMessage = dbResponse["message"]! as! String
                }
                
                // Returns the code execution flow back to the main thread
                DispatchQueue.main.async(execute: {
                    // Displays a message to the user indicating the successful/unsuccessful creation of a new pack
                    // Checks if there was an error with the database interaction
                    if isError{
                        // Alerts the user of the error
                        let alertCon = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                            // If the database interaction was a search request then the pack store list table view is dismissed
                            if api == "packSearch.php"{ self.dismiss(animated: true, completion: nil) }}))
                        self.present(alertCon, animated: true, completion: nil)
                    } else{ // No errors found
                        // Checks if the database interaction was a search request
                        if api == "packSearch.php"{
                            // The search result (list of packs) is retrieved
                            let searchResults = dbResponse["searchResult"] as! [[String: String]]
                            self.loadDataIntoTable(data: searchResults) // Search result is loaded into the table
                            self.updateInfoBarMessage(message: "\(searchResults.count) Pack(s) Found") // Number of results is displayed
                        // Checks if the database interaction was to download the pins from a pack
                        } else if api == "getPinsFromPack.php"{
                            // Pin contains flag is set
                            let packContainsPinsFlag = dbResponse["packContainsPinsFlag"]! as! Bool
                            // Checks if the pack contains pins
                            if  packContainsPinsFlag { // Pins are saved
                                self.preparePackToSave(pins: dbResponse["Pins"] as! [[String: String]], didContainPins: true)
                            } else{ // An empty array for the pins are saved
                                self.preparePackToSave(pins: [[:]], didContainPins: false)
                            }
                        }
                    }

                })
            }
        } else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the retrieveDataFromDatabase function until internet connectivity is restored
                self.retrieveDataFromDatabase(api: api, postData: postData)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }

    //[---------------------- System Buttons --------------------------------]
    
    // Changes the title (text) displayed in the number of results info bar
    private func updateInfoBarMessage(message: String){
        infoBarButton.setTitle(message, for: UIControlState())
    }
    
    // Connects the back button with the code
    // - Dismisses the view when tapped
    @IBAction func backNavBarButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Connects the help button with the code
    // - Displays an alert with information about how to interact with the table
    @IBAction func helpButtonTapped(_ sender: Any) {
        var alertMessage = "Tap a pack to"
        if loadLocalPacksFlag == true{
            alertMessage = alertMessage + " delete it from the phone"
        } else{
            alertMessage = alertMessage + " download it onto the phone"
        }
        displayAlertMessage(alertTitle: "Help", alertMessage: alertMessage)
    }
    

}
