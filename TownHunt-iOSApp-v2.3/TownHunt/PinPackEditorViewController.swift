//
//  AddNewMapPacksViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic behind the pin pack editor

import UIKit // UIKit constructs and manages the app's UI
import MapKit // MapKit constructs and manages the map and annotations

// Class controls the pin pack editor view
class PinPackEditorViewController: PinPackMapViewController, MKMapViewDelegate{
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
        // UI elements found in the info bar (just below the orange nav bar)
    @IBOutlet weak var viewBelowNav: UIView! // Background of the info bar
    @IBOutlet weak var totalPinsButtonLabel: BorderedButton!
    @IBOutlet weak var maxPointsButtonLabel: BorderedButton!
    @IBOutlet weak var packUnplayableWarningButton: UIButton! // Warning that the pack is currently unplayable

        // UI elements which relate to the new pin information form
    @IBOutlet weak var addPinDetailView: UIView! // The form container
    @IBOutlet weak var pinTitleTextField: UITextField!
    @IBOutlet weak var pinHintTextField: UITextField!
    @IBOutlet weak var pinCodewordTextField: UITextField!
    @IBOutlet weak var pinPointValTextField: UITextField!
        // The map UI element
    @IBOutlet weak var mapView: MKMapView!

    // Initialises attributes which will hold details about the selected pack and creator
    public var selectedPackKey = ""
    public var userPackDictName = ""
    public var userID = ""
    public var filename = ""
    public var packData = [:] as [String: Any]
    public var gamePins: [PinLocation] = []
    
    // Initialises details about the new pin
    private var newPLat = 0.0 // New Pin latitude coordinate
    private var newPLong = 0.0 // New pin longitude coordinate
    private var isNewPinOnMap = false
    private var newPinCoords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    private let newPin = MKPointAnnotation() // New pin map annotation
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Starts the process of retrieving the selected pack data from local storage
        loadInitialPackData()
        
        // Sets up an event listener (listening for the pin list to close). If the event is detected then the annotations are refreshed
        NotificationCenter.default.addObserver(self, selector: #selector(PinPackEditorViewController.refreshAnnotations(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        // Sets up detector to detect where a long press on the screen has occurred. At this point on the screen a pin will be dropped
        let longPressRecog = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        longPressRecog.minimumPressDuration = 1.0 // Press has to be a min of 1 second
        mapView.addGestureRecognizer(longPressRecog) // Adds the detector to the map
        
        // Updates the pack info labels
        updatePackLabels()
        
        // Setting up the map view
        mapView.showsUserLocation = true // Sets up the default map to a satellite map with road names
        mapView.mapType = MKMapType.hybrid
        mapView.delegate = self // Gives this class the ability to control the map UI element
        mapView.addAnnotations(gamePins) // Adds the pins already in the pack to the map

    }
    
    // Updates the pack info labels
    private func updatePackLabels(){
        // New pin count is determined and displayed
        totalPinsButtonLabel.setTitle("Total Pins: \(gamePins.count)", for: UIControlState())
        // Checks if the pack is playable i.e. contains more than 5 pins
        // If a pack isn't playable a warning sign will appear on screen
        if gamePins.count >= 5{
            packUnplayableWarningButton.isHidden = true
        } else{
            packUnplayableWarningButton.isHidden = false
        }
        // Calculates the max number of points available in the pack
        var maxPoints = 0
            // Loops through each pin and appends the point value to a running total
        for pin in gamePins{
            maxPoints += pin.pointVal
        }   // Displays the point total
        maxPointsButtonLabel.setTitle("Max Points: \(maxPoints)", for: UIControlState())
    }
    
    // [--------------------------- Pin Mechanics --------------------------------]
    
    // Refreshes all of the pins (annotations) on the map
    func refreshAnnotations(_ notification: Notification){
        mapView.addAnnotations(gamePins) // Pins in the pack are added to the map
        updatePackLabels()
    }
    
    // Resets the new pin details form
    private func resetTextFieldLabels(){
        isNewPinOnMap = false
        // Clears the form
        pinTitleTextField.text = ""
        pinHintTextField.text = ""
        pinCodewordTextField.text = ""
        pinPointValTextField.text = ""
    }
    
    // Adds a new pin (annotation) to the map if there isn't already one currently on the map
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        // Checks if there is already a new pin on the map
        if isNewPinOnMap == false{
            // Gets coordinates of the long tap
            let touchLocation = gestureRecognizer.location(in: mapView)
            newPinCoords = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            newPin.coordinate = newPinCoords // Sets the new pin's coord as where the long tap occured
            mapView.addAnnotation(newPin) // Adds pin to map
            isNewPinOnMap = true
        }
    }
    
    // Connects add pin details button to the code
    // - Presents a form to the user where info about the new pin can be entered
    @IBAction func addPinDetailsButton(_ sender: AnyObject) {
        // Checks if there is a new pin on the map
        if isNewPinOnMap == true{
            // Zooms and centres on the new pin
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:  newPinCoords.latitude + 0.0003, longitude:  newPinCoords.longitude), 100, 100)
            mapView.setRegion(region, animated: true)
            // Presents the form
            addPinDetailView.isHidden = false
        } else{ // If no new pin is detected an error message is presented
            displayAlertMessage(alertTitle: "No New Pin On The Map", alertMessage: "A new pin hasn't been added to the map yet. Long hold on the location you want to place the pin")
        }
    }
    
    // Connects the cancel adding new pin button to the code
    // - Removes the new pin and dismisses the form to add details
    @IBAction func cancelAddPinDetButton(_ sender: AnyObject) {
        // Dismisses the form
        addPinDetailView.isHidden = true
        view.endEditing(true)
        // Removes the new pin from the map
        mapView.removeAnnotation(newPin)
        // Resets the pin detail form text fields
        resetTextFieldLabels()
    }
    
    // Connects the save new pin button to the code
    // - Validates the new pin details and appends it to the pack pins array
    @IBAction func saveAddPinDetButton(_ sender: AnyObject) {
        // Checks if the point value entered was an integer
        if let pointNum = Int(pinPointValTextField.text!){
            
            // Retrieves user input for the pin details
            let pinTitle = pinTitleTextField.text!
            let pinHint = pinHintTextField.text!
            let pinCodeword = pinCodewordTextField.text!
            
            // Check for empty fields
            if((pinTitle.isEmpty) || (pinHint.isEmpty) || (pinCodeword.isEmpty)) {
                // Displays data entry error message
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
                
            //Checks the character length of the pin title
            } else if pinTitle.characters.count > 140{
                // Displays pin title character length error message
                displayAlertMessage(alertTitle: "Pin Title is Greater Than 140 Characters", alertMessage: "Please enter a title which is less than or equal to 140 characters")
                
            //Checks the character length of the pin hint
            }else if((pinHint.characters.count) > 140){
                // Displays pin hint character length error message
                displayAlertMessage(alertTitle: "Pin Hint is Greater Than 140 Characters", alertMessage: "Please enter a hint which is less than or equal to 140 characters")
            
            //Checks the character length of the pin codeword
            }else if((pinCodeword.characters.count) > 140){
                // Displays pin codeword character length error message
                displayAlertMessage(alertTitle: "Pin Codeword is Greater Than 140 Characters", alertMessage: "Please enter a codeword which is less than or equal to 140 characters")
                
            //Checks the character length of the pin value
            }else if((String(pointNum).characters.count) > 10){
                // Displays pin value character length error message
                displayAlertMessage(alertTitle: "Pin Value is Greater Than 10 Characters", alertMessage: "Please enter a point value which is less than or equal to 10 characters")
            } else { // Pin is validated
                // Creates an instance of a PinLocation with the new pins details
                let pin = PinLocation(title: pinTitle, hint: pinHint, codeword: pinCodeword, coordinate: newPinCoords, pointVal: pointNum)
                // Adds the new pin to the pack pins array
                mapView.addAnnotation(pin)
                mapView.removeAnnotation(newPin)
                addPinDetailView.isHidden = true // Hides the pin details form
                resetTextFieldLabels() // Resets the pin details form
                gamePins.append(pin)
                updatePackLabels()  // Updates pack stats
                view.endEditing(true)
            }
        } else {
            // Displays invalid point value type error
            displayAlertMessage(alertTitle: "Invalid Point Value", alertMessage: "Please enter a number (integer) into the point value")
        }
    }
    
    // Retrieves the selected pack details and loads it into the view
    private func loadInitialPackData(){
        let defaults = UserDefaults.standard
        // Checks that the dictionary which contains the local packs made by the user exists
        if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
            filename = dictOfPacksOnPhone[selectedPackKey] as! String // Retrieves file name
            packData = loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: userID) // Retrieves pack info
            gamePins =  getListOfPinLocations(packData: packData) // Retrieves pins in the pack
        } else{ // Error message is displayed indicating that there was an error in loading the file
            displayAlertMessage(alertTitle: "Error", alertMessage: "File Couldn't be loaded")
        }
    }
    
    // Method which saves the current pack to both local storage and the online database
    private func savePack(){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // Prepares the pack data to save
            var jsonToWrite = packData
            var pinsToSave = [[String: String]]()
            // Retrieves a dictionary about the info of each PinLocation Object and appends it to a 'pinToSave' list
            for pin in gamePins{
                pinsToSave.append(pin.getDictOfPinInfo())
            }
            jsonToWrite["Pins"] = pinsToSave
            
            // Stores the pack details (JSON file) to local storage via the LocalStorageHandler class in the logged in user's folder
            let storageHandler = LocalStorageHandler(fileName: filename, subDirectory: "UserID-\(packData["CreatorID"]!)-Packs", directory: .documentDirectory)
            let localStorageResponse = storageHandler.saveEditedPack(packData: jsonToWrite as [String : Any])
            
            // If there is an error with saving the json file, the user is presented with an alert with details of the error
            if (localStorageResponse["error"] as! Bool){
                displayAlertMessage(alertTitle: "Error", alertMessage: localStorageResponse["message"] as! String)
            } else{ // File successfully saved
                
                // The data to send to the database is received and set up for POSTing to the API
                let dataToPost = localStorageResponse["data"] as! [String: Any]
                
                // Converts dictionary into a JSON string
                let convertedDataToPost = "data=\(storageHandler.jsonToString(jsonData: dataToPost))"
                print(convertedDataToPost)
                
                // If there is internet connectivity then the data is posted to the online database API via the DatabaseInteraction class on the background thread.
                // The "updatePinPack.php" API attempts to update the pin pack details
                let responseJSON = dbInteraction.postToDatabase(apiName: "updatePinPack.php", postData: convertedDataToPost){ (dbResponse: NSDictionary) in
                    
                    // Instantiates the alert details
                    var alertTitle = ""
                    var alertMessage = ""
                    
                    // The alert details is set depending on if there was a database error
                    if dbResponse["error"]! as! Bool{
                        alertTitle = "Error"
                        alertMessage = dbResponse["message"]! as! String
                    } else if !(dbResponse["error"]! as! Bool){
                        alertTitle = "Success"
                        alertMessage = dbResponse["message"]! as! String
                    }
                    // Returns the code execution flow to the main thread
                    DispatchQueue.main.async(execute: {
                        // Displays a message to the user indicating the successful/unsuccessful creation of a new pack
                        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                // Dismisses view
                                self.dismiss(animated: true, completion: nil)
                            }))
                        self.present(alertCon, animated: true, completion: nil)
                    })
                }
            }
        }else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the savePack function until internet connectivity is restored
                self.savePack()
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }
    
    // [----------------------------System Mechanics-----------------------------------------]
    
    
    // Connects the Zoom button to the code
    // - This centres the map around the user as well as increasing the magnification of the map
    @IBAction func zoomButton(_ sender: AnyObject) {
        // Checks if the phone's GPS location is currently available
        if mapView.isUserLocationVisible == true {
            // If user's location is found the map region is set to the 200x200m area around the user
            let userLocation = mapView.userLocation
            let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
            mapView.setRegion(region, animated: true)  // Updates the UI map
        } else {
            // If user's location is not found an error message is presented to the user
            displayAlertMessage(alertTitle: "GPS Signal Not Found", alertMessage: "Cannot zoom on to your location at this moment\n\nIf you have disabled TownHunt from accessing your location, please go to the settings app and allow TownHunt to access your location")
        }
    }
    
    // Connects the back button to the code
    // - Dismisses the view, with or without saving the pack depending on the user's choice
    @IBAction func backButtonTapped(_ sender: Any) {
        // An exit menu is displayed
        let alertCon = UIAlertController(title: "Do you want to save the changes to your pack before leaving?", message: "Select 'Cancel' to return to the editor", preferredStyle: .actionSheet)
        alertCon.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            // If the user opts to save the pack then the savePack method is called
            self.savePack()
        }))
        alertCon.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            // If the user opts to not save the pack then the view is dismissed without any changes being saved
            self.dismiss(animated: true, completion: nil)
        }))
        alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // Cancel returns to the editor
        self.present(alertCon, animated: true, completion: nil)
    }
    
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks that the segue identifier is "PackEditorToListOfPins"
        if segue.identifier == "PackEditorToListOfPins" {
            // Retrieves the segue destination's navigation controller
            let destNavCon = segue.destination as! UINavigationController
            // Checks if the next view controller is of the PinListInPackTableViewController class
            if let targetController = destNavCon.topViewController as? PinListInPackTableViewController{
                targetController.listOfPins = gamePins // Pack pins array is passed
                mapView.removeAnnotations(gamePins) // Map annotations are cleared in the editor
                gamePins = [] // Game pins array is reset
            }
        // Checks that the segue identifier is "PackEditorToPackDetail"
        } else if segue.identifier == "PackEditorToPackDetail" {
            // Checks if the next view controller is of the PackDetailsViewController class
            if let nextVC = segue.destination as? PackDetailsViewController{
                // The current pack's details are passed without the pins
                var packDetails = packData
                packDetails.removeValue(forKey: "Pins")
                nextVC.packDetails = packDetails as! [String : String]
            }
        }
    }
    
}
