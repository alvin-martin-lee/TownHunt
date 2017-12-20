//
//  MainGameScreenViewController.Swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic behind the main game screen.

import UIKit // UIKit constructs and manages the app's UI
import MapKit // MapKit constructs and manages the map and annotations

// Sets up the delegate protocol - Once the modally presented view (pack selector) has closed, 'packSelectedHandler' is called
protocol MainGameModalDelegate {
    // Variables from the pack selector are passed into this class via this function
    func packSelectedHandler(selectedPackKey: String, packCreatorID: String, gameType: String)
}

// Class acts as the logic behind the main game screen view
class MainGameScreenViewController: PinPackMapViewController, MKMapViewDelegate, MainGameModalDelegate {
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
        // UI elements found on the top orange navigation bar
    @IBOutlet weak var endGameButton: UIBarButtonItem!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
        // UI elements found in the info bar (bar below the navigation bar)
    @IBOutlet weak var viewBelowNav: UIView! // The background of the info bar
    @IBOutlet weak var startButton: UIButton! // Also used as an outlet to display the time remaining
    @IBOutlet weak var pointsButton: BorderedButton! // Also used as a button which leads to information on the selected pack details
        // The map UI element
    @IBOutlet weak var mapView: MKMapView!
        // UI elements of the pack info bars
    @IBOutlet weak var packSelectedButton: UIButton!
    @IBOutlet weak var gameTypeButton: UIButton!
        // The select pin pack button
    @IBOutlet weak var selectPinPackButton: BorderedButton!

    // Initialises attributes which will hold details about the selected pack and player
    public var filename = ""
    public var selectedPackKey = ""
    public var userPackDictName = ""
    public var packCreatorID = ""
    public var gameType = "competitive"
    private var packData: [String:Any] = [:]
    private var playerUserID: String = ""
    
    // Initialises attributes relating the actual game mechanics
    private var timer = Timer()
    private var isPackLoaded = false
    private var isGameOn = false
    private var countDownTime = 0
    private var points = 0
    private var timeToNextNewPin = 0
    private var activePins: [PinLocation] = [] // Holds pins which are currently displayed on the map
    private var gamePins: [PinLocation] = [] // Holds pins which are in the selected pack
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()

        // Check if this is the first time the app has been launched
        checkFirstLaunch()
        
        // Prevents the phone from going to sleep and turning the screen off
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Connects the menu button to the menu screen
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Sets up the map view
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid // Sets up the default map to a satellite map with road names
        mapView.delegate = self // Gives this class the ability to control the map UI element
        
        // Checks if a user is logged in
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        // If no user is logged in the login screen is immediately called
        if(!isUserLoggedIn){
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    // Checks if user has launched the app before, if not calls the initial file setup
    private func checkFirstLaunch(){
        let defaults = UserDefaults.standard
        // If app has already launched "isAppAlreadyLaunchedOnce" flag will be set i.e. not nil
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            print("App already launched")
        } else {
            // "isAppAlreadyLaunchedOnce" flag is set to true
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            // Initial set up class is called and the pack linked list system is setup
            FirstLoadSetup().initialSetup()
        }
    }
    
    // [------------------MAP & PIN MECHANICS------------------------------------------------------]
    
    // Connects the Zoom button to the code
    // - This centres the map around the user as well as increasing the magnification of the map
    @IBAction func zoomOnUser(_ sender: AnyObject) {
        // Checks if the phone's GPS location is currently available
        if mapView.isUserLocationVisible == true {
            // If user's location is found the map region is set to the 200x200m area around the user
            let userLocation = mapView.userLocation
            let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
            mapView.setRegion(region, animated: true)  // Updates the UI map
        } else {
            // If user's location is not found an error message is presented to the user
            displayAlertMessage(alertTitle: "GPS Signal Not Found", alertMessage: "Cannot zoom on to your location at this moment.\n\nIf you have disabled TownHunt from accessing your location, please go to the settings app and allow TownHunt to access your location")
        }
    }
    
    // Connects the Change Map button to the code 
    // - Changes the map type from a hybrid satellite map to the standard map (no satellite imagery) and vice versa
    @IBAction func changeMapButton(_ sender: AnyObject) {
        if mapView.mapType == MKMapType.hybrid{
            mapView.mapType = MKMapType.standard
            viewBelowNav.backgroundColor = UIColor.brown.withAlphaComponent(0.8) // Changes the info bar's colour to brown
        } else {
            mapView.mapType = MKMapType.hybrid
            viewBelowNav.backgroundColor = UIColor.white.withAlphaComponent(0.8) // Changes the info bar's colour to white
        }
    }
    
    // MKMapViewDelegate method which creates the annotations (Pins) and their 'callouts'
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PinLocation"
        // Checks if the annotation is a pin (PinLocation class)
        if annotation is PinLocation {
            // Returns a reusable annotation view located by the identifier "PinLocation".
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            // If no free views exist then a new view is created
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) // New Annotation view
                annotationView!.canShowCallout = true // Enables callouts
                // Sets up the info button symbol on the callout
                let infoButton = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = infoButton
            } else {
                // If a reusable annotation view is found then the annotation object is retrieved
                annotationView!.annotation = annotation
            }
            // Annotation view is returned
            return annotationView
        }
        return nil // Nil is returned if the annotation is not of the PinLocation class
    }
    
    // MKMapViewDelegate method which is called when the pin has been tapped.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Retrieves details about the pin which has been tapped by accessing attributes from the instance
        let pin = view.annotation as! PinLocation
        let pinTitle = "\(pin.title!) : (\(pin.pointVal) Points)"
        let pinHint = pin.hint
        
        // Creates an alert where information about the pin is displayed.
        let alertCon = UIAlertController(title: pinTitle, message: pinHint, preferredStyle: .alert)
        // Adds an answer box to the alert. Here, the codeword found can be entered
        alertCon.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Enter codeword:"})
        // Adds an OK button to the alert
        alertCon.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
            // If the OK button is tapped, the user's entered codeword is checked
            let userInput = alertCon.textFields![0] as UITextField
            
            // Checks if the codeword entered matches the one found on the pin
            if (userInput.text?.lowercased() == pin.codeword.lowercased()){
                self.points += pin.pointVal // Increments point value
                self.updatePointsLabel() // Updates UI display
                pin.isFound = true
                
                let currentPinIndex = self.activePins.index(of: pin) // Gets index of the pin
                self.activePins.remove(at: currentPinIndex!) // Removes the pin from the active pin index
                mapView.removeAnnotation(pin) // Removes pin from the map
                self.alertCorrectIncor(true, pointVal: pin.pointVal) // Tells the user that the codeword entered is correct
            } else {
                self.alertCorrectIncor(false, pointVal: pin.pointVal) // Tells the user that the codeword entered is incorrect
            }
        }))
        // Presents the alert to the user
        present(alertCon, animated: true, completion: nil)
    }
    
    // [------------------------------------ PACK SELECTOR MECHANICS----------------------------------------------------]
    
    // Connects the Select Pin Pack Button to the code
    // - Instantiates the pack selector
    @IBAction func selectPinPackButtonTapped(_ sender: Any) {
        // Retrieves the pack selector UI elements from the UI storyboard editor
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"packSelector") as! MainGamePackSelectorViewController
        viewController.delegate = self // Sets the pack selector's delegate as the main game screen view (current view)
        self.present(viewController, animated: true) // Presents the pack selector
    }
    
    // Method which retrieves the details of the pack selected from the Pack Selector
    func packSelectedHandler(selectedPackKey: String, packCreatorID: String, gameType: String){
        playerUserID = UserDefaults.standard.string(forKey: "UserID")! // Retrieves the id of the user logged in
        self.selectedPackKey = selectedPackKey
        self.packCreatorID = packCreatorID
        self.gameType = gameType
        // Checks if the selected pack key, pack creator id and the game type was passed
        if !(self.selectedPackKey.isEmpty || self.packCreatorID.isEmpty || self.gameType.isEmpty){
            userPackDictName = "UserID-\(packCreatorID)-Packs"
            let defaults = UserDefaults.standard
            // Checks if the dictionary containing the list of packs made by a specified creator exists
            if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
                filename = dictOfPacksOnPhone[selectedPackKey] as! String
                // Loads pack data from the file
                packData = loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: packCreatorID)
                // Loads the pack pins into the gamePins array
                gamePins =  getListOfPinLocations(packData: packData)
                isPackLoaded = true
                // Displays the info bars which contain details about the user selection
                    // Displays what pack was selected
                packSelectedButton.isHidden = false
                packSelectedButton.setTitle("Pack Selected: \(selectedPackKey)", for: UIControlState())
                    // Displays what game type was selected
                gameTypeButton.isHidden = false
                gameTypeButton.setTitle("Game Type: \(gameType.uppercased())", for: UIControlState())
            } else { // If creator's dictionary could not be found then an error message is displayed
                displayAlertMessage(alertTitle: "Error", alertMessage: "Data Couldn't be loaded")
            }
        } else {// If data was not passed an error message is displayed
            displayAlertMessage(alertTitle: "Error", alertMessage: "Selected pack data not passed.")
        }
        
    }
    
    // [------------------------------- GAME MECHANICS ------------------------------------]
    
    // Resets the game to the default game settings (specified in the selected pack details)
    private func resetGame(){
        
        // Resets game variables
        countDownTime = Int(packData["TimeLimit"] as! String)! * 60 // Resets countdown timer (in seconds)
        points = 0
        isGameOn = false
        timeToNextNewPin = 0
        activePins = []
        gamePins = getListOfPinLocations(packData: packData) // Reloads gamePins with pins from the selected pack data
        pointsButton.setTitle("Points: 0", for: UIControlState())
        
        // Unhides select pin pack button
        selectPinPackButton.isHidden = false
        // Re-enables menu button
        menuOpenNavBarButton.accessibilityElementsHidden = false
        menuOpenNavBarButton.isEnabled = true
        // Unhides the info bars which contain details about the user selection
        packSelectedButton.isHidden = false
        gameTypeButton.isHidden = false
    }
    
    // Method is called when the start button is tapped
    // - Starts the game if certain criteria are met
    @IBAction func startButtonTapped(_ sender: AnyObject) {
        // Checks if game is in progress
        if isGameOn == false{
            // Checks if pack has been loaded
            if isPackLoaded == false {
                // If no pack is loaded then an error message is displayed
                displayAlertMessage(alertTitle: "No Pin Pack Selected", alertMessage: "Tap 'Select Pin Pack' to chose a pack")
            // Checks if there is too few pins (less than 5) in the pack
            }else if gamePins.count < 4{
                // Error message is displayed
                displayAlertMessage(alertTitle: "Too Few Pins", alertMessage: "The selected pack has too few pins please add more")
            }
            else{
                // Game is started
                
                timeToNextNewPin = randomTimeGen(countDownTime/5) // Random time, till a pin is added to the map, is generated
                resetGame()
                // Hides the info bars which contain details about the user selection
                packSelectedButton.isHidden = true
                gameTypeButton.isHidden = true
                // Hides select pin pack button
                selectPinPackButton.isHidden = true
                // Disables menu button
                menuOpenNavBarButton.isEnabled = false
                // Enables end game button
                endGameButton.isEnabled = true
                // Game in progress flag is updated to true
                isGameOn = true
                
                // Checks if the logged in user is playing a pack made by him/her
                if playerUserID == packCreatorID{
                    displayAlertMessage(alertTitle: "You Made This Pack!", alertMessage: "Since you created this pack, your score will not be uploaded to the leaderboard")
                }
                
                // Checks what game type the user wants to play
                if gameType == "competitive"{ // Competitive mode is selected
                    // Five random pins from the pack are added to the the active pins array
                    for _ in 0...3{
                        addRandomPinToActivePinList()
                    }
                    // The pins in the active pins array are added to the map as Annotations
                    mapView.addAnnotations(activePins)
                    // Timer is set up - updateTime method is called every second
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainGameScreenViewController.updateTime), userInfo: nil, repeats: true)
                    // Starts the timer
                    updateTime(timer)
                } else { // Casual mode is selected
                    // All game pins are added to the active pins array
                    activePins = gamePins
                    // All active pins are added to the map
                    mapView.addAnnotations(activePins)
                    // Indicates to the user that casual mode is being played
                    startButton.setTitle("Casual Mode", for: UIControlState())
                    displayAlertMessage(alertTitle: "Casual Mode Game", alertMessage: "There is no time limit so take your time to explore and hunt for the pins! Once you have finished tap 'End Game'")
                }
            }
        }
    }

    // Updates the points button's title to the current score
    private func updatePointsLabel(){
        pointsButton.setTitle("Points: \(points)", for: UIControlState())
    }
    
    // Updates the timer
    func updateTime(_ timer: Timer){
        // Checks if the countdown time has reached 0
        if(countDownTime > 0 && isGameOn == true){
            // Updates the timer displayed to the user
            let minutes = String(countDownTime / 60) // Calculates the minutes part of the time left
            let seconds = countDownTime % 60 // Using modulo, Calculates the seconds part of the time left
            // To keep the seconds display two characters long, if the seconds is less than 10, an 0 is appended infront
            var secondsToDisplay = ""
            if seconds < 10{
                secondsToDisplay = "0" + String(seconds)
            } else{
                secondsToDisplay = String(seconds)
            }
            // The start button doubles up as the timer display. It is updated with the current time left
            startButton.setTitle(minutes + ":" + secondsToDisplay, for: UIControlState())
            // Count down time is decremented by one
            countDownTime -= 1
            print(timeToNextNewPin)
            // Checks if the time to next new pin is greater than 0
            if timeToNextNewPin > 0{
                // Time to next pin is decremented by one
                timeToNextNewPin -= 1
            // Checks if time to next new pin is 0 and there are still pins to add to the game
            } else if (timeToNextNewPin == 0 && gamePins.isEmpty == false){
                addRandomPinToActivePinList() // Calls a method which will add a new pin to the map
                timeToNextNewPin = randomTimeGen(countDownTime/5) // Sets a new random time to next pin
            }
            
            // Checks if there are any pins on the map
            if activePins.count == 0{
                    addRandomPinToActivePinList() // Calls a method which will add a new pin to the map
            }
            
        } else { // If countdown timer is 0, the game is ended
            endGame()
        }
    }
    
    // Creates the alert telling the user if the codeword entered was correct or incorrect
    private func alertCorrectIncor(_ isCorrect: Bool, pointVal: Int){
        var alertTitle: String = ""
        var alertMessage: String = ""
        // Checks if the isCorrect flag is true
        if isCorrect == true{
            alertTitle = "Well Done!"
            alertMessage = "\(pointVal) Points Added"
            Sound().playSound("CorrectSound") // A 'correct' sound is played
        } else {
            alertTitle = "Incorrect!"
            alertMessage = "Try Again!"
            Sound().playSound("Wrong-answer-sound-effect") // An 'incorrect' sound is played
        }
        // Displays the outcome to the user
        displayAlertMessage(alertTitle: alertTitle, alertMessage: alertMessage)
    }
    
    // Generates (and returns) a random number between 0 and maxNum
    private func randomTimeGen(_ maxNum: Int) -> Int{
        return Int(arc4random_uniform(UInt32(maxNum)))
    }
    
    // Adds a random pin from the gamePin array to the map screen
    private func addRandomPinToActivePinList(){
        Sound().playSound("Message-alert-tone") // A sound is played to alert the user that a new pin has been added
        let newPinIndex = randomTimeGen(gamePins.count) // Random pin index is selected
        self.mapView.addAnnotation(gamePins[newPinIndex]) // A pin and the random index is added to the map
        activePins.append(gamePins[newPinIndex]) // The pin is appended to the active pins array
        gamePins.remove(at: newPinIndex) // The pin is removed from the game pins array
    }
    
    // Method is called when the end game button is tapped
    // - Ends the game before the count down timer has reached 0
    @IBAction func endGameButtonTapped(_ sender: AnyObject) {
        // Sets up a confirmation alert to the user to confirm that the user really want to the end the game
        let alert = UIAlertController(title: "End the Game", message: "Do you really want to end the game ", preferredStyle: .alert)
        // A 'Yes' option is added to the alert
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action) -> Void in
            // If pressed then the game will end
            self.endGame()
        })
        alert.addAction(yesAction)
        // A 'Cancel' option is added, just in case the end game button was tapped accidentally
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil) // Alert is displayed to user
    }
    
    // Method which ends the game
    private func endGame(){
        Sound().playSound("Game-over-yeah") // Play a sound to indicate to the user that the game has ended
        timer.invalidate() // Ends the timer
        startButton.setTitle("Start", for: UIControlState())
        isGameOn = false
        // Checks if the user who played the pack was the one who created it
        if playerUserID != packCreatorID{
            // If not then a method is called to add the score to the database
            addRecordToDB(score: String(points))
        }
        self.mapView.removeAnnotations(activePins) // The map is cleared of pins/annotations
        endScreen() // End screen is displayed
        resetGame()
        pointsButton.setTitle("Pack Details", for: UIControlState())
        endGameButton.isEnabled = false
    }
    
    // Method which displays the end screen after the game has ended
    private func endScreen(){
        // Displays "GAME OVER" and the final score to the user
        displayAlertMessage(alertTitle: "GAME OVER!", alertMessage:  "You Scored \(points).")
    }
    
    // Sends the score and player user id to the database
    private func addRecordToDB(score: String){
        // Retrieves pack ID
        let packID = packData["PackID"] as! String
        // Sets up the string to be posted
        let postData = "PackID=\(packID)&PlayerUserID=\(playerUserID)&Score=\(score)&GameType=\(gameType)"
        
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            // If there is internet connectivity then the data is posted to the online database API via the dbInteraction class on the background thread.
            // The "addPlayedPackRecord.php" API adds first time scores of a pack to the online database
            let responseJSON = dbInteraction.postToDatabase(apiName: "addPlayedPackRecord.php", postData: postData){ (dbResponse: NSDictionary) in
                
                // Retrieves the database response
                let isError = dbResponse["error"]! as! Bool
                let dbMessage = dbResponse["message"]! as! String
                
                // Displays a message to the user indicating whether the score was received
                DispatchQueue.main.async(execute: { // Returns to the main thread
                    if isError{ // If there is an error it is displayed to the user
                        self.displayAlertMessage(alertTitle: "Error", alertMessage: dbMessage)
                    } else{
                        print("Score successfully sent to database API")
                    }
                    
                })
            }
        } else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall  addRecordToDB until internet connectivity is restored
                self.addRecordToDB(score: score)
            }))
            // Alert is presented to user
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    // [----------------------------System Mechanics-----------------------------------------]
    
    // System function which is called to check whether the transition to the next view should be allowed
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        // Checks if a segue identifier was passed
        if let segueIdentifier = identifier {
            // Check if identifier was "MainGameScreenToPackDetail"
            if segueIdentifier == "MainGameScreenToPackDetail" {
                // Checks if a pack is loaded
                if isPackLoaded == false {
                    // If no pack is loaded then an alert message is displayed
                    displayAlertMessage(alertTitle: "No Pack is Loaded", alertMessage: "Tap 'Select Pin Pack' to chose a pack")
                    return false // Transition to the pack detail view is not allowed
                // Checks if the game is on
                } else if isGameOn {
                    // If the game is in progress
                    return false // Transition to the pack detail view is not allowed
                }
            }
        }// Otherwise the // Transition to the pack detail view is allowed
        return true
    }
    
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks that the segue identifier is "MainGameScreenToPackDetail"
        if segue.identifier == "MainGameScreenToPackDetail" {
            // Checks if the next view controller is of the PackDetailViewController class
            if let nextVC = segue.destination as? PackDetailsViewController{
                // Passes data from the current main game view to the next pack detail view
                //  - Passes the pack details without the pins
                var packDetails = packData
                packDetails.removeValue(forKey: "Pins")
                nextVC.packDetails = packDetails as! [String : String]
                nextVC.isPackDetailsEditable = false // Doesn't allow the pack details to be edited
            }
        }
    }
}
