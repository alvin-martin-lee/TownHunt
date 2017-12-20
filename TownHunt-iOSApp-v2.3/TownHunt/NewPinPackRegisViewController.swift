
//
//  NewPinPackCreationViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the new pin pack registration page

import UIKit // UIKit constructs and manages the app's UI

// Class controls the new pin pack view
class NewPinPackRegisViewController: FormTemplateExtensionOfViewController {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var briefDescripTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var gameTimeTextLabel: UILabel!
    @IBOutlet weak var timeControlStepper: UIStepper! // Two buttons ("+" and "-") which can be used to (de)increment the game time
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()

        // Sets the background image
        setBackgroundImage(imageName: "newPackDetailsBackgroundImage")
        
        // Sets the initial game type label value
        timeStepperAction(Any.self)
    }
    
    // Connects the stepper to the code
    // - Function is called every time the stepper is tapped. It updates the game time label
    @IBAction func timeStepperAction(_ sender: Any) {
        gameTimeTextLabel.text = "Game Time: \(Int(timeControlStepper.value)) mins"
    }
    
    // Connect the create pack button to the code
    // - Registers new pack with the database and saves the new pack to the phone
    @IBAction func createPackButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // Initialises pack data variables obtained from the registration form
            let packName = packNameTextField.text
            let packLocation = locationTextField.text
            let packDescrip = briefDescripTextField.text
            let creatorID = UserDefaults.standard.string(forKey: "UserID")
            let creatorName = UserDefaults.standard.string(forKey: "Username")
            let gameTime = String(Int(timeControlStepper.value))
            
            // Check for empty fields
            if((packName?.isEmpty)! || (packLocation?.isEmpty)! || (packDescrip?.isEmpty)!) {
                // Display data entry error message
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
            
            //Checks the character length of the pack name
            } else if((packName?.characters.count)! > 30){
                //Displays pack name character length error message
                displayAlertMessage(alertTitle: "Packname is Greater Than 30 Characters", alertMessage: "Please enter a pack name which is less than or equal to 30 characters")
                
            //Checks the character length of the pack location
            } else if((packLocation?.characters.count)! > 30){
                //Displays pack location chararacter length error message
                displayAlertMessage(alertTitle: "Pack Location is Greater Than 30 Characters", alertMessage: "Please enter a location in less than or equal to 30 characters")
            
            //Checks the character length of the pack description
            } else if((packDescrip?.characters.count)! > 30){
                //Displays pack description chararacter length error message
                displayAlertMessage(alertTitle: "Pack Description is Greater Than 30 Characters", alertMessage: "Please enter a description which is less than or equal to 30 characters")
        
            } else{
                // A post string is posted to the online database API via the DatabaseInteraction class on the background thread
                // The "registerNewPinPack.php" API attempts to add the new pin pack details to the online database and retrieves the new pin pack's id
                let responseJSON = dbInteraction.postToDatabase(apiName: "registerNewPinPack.php", postData: "packName=\(packName!)&description=\(packDescrip!)&creatorID=\(creatorID!)&location=\(packLocation!)&gameTime=\(gameTime)"){ (dbResponse: NSDictionary) in
                    
                    // Default error variables initialised
                    var alertTitle = "ERROR"
                    var alertMessage = "JSON File Invalid"
                    var isNewPackRegistered = false
                    
                    // If a database error exists, the  database response message is presented to the user
                    if dbResponse["error"]! as! Bool{
                        alertTitle = "ERROR"
                        alertMessage = dbResponse["message"]! as! String
                    } // If there is no database error the JSON file is saved
                    else if !(dbResponse["error"]! as! Bool){
                        
                        // Prepares pack details/info to save to local storage
                        let fileName = packName?.replacingOccurrences(of: " ", with: "_")
                        let packInfo = dbResponse["packData"] as! NSDictionary
                        let packID = packInfo["PackID"]! as! String
                        
                        // The NSDictionary which will become the JSON file
                        let jsonToWrite = ["PackName": packName!, "Description": packDescrip!, "PackID": packID, "Location": packLocation!, "TimeLimit": gameTime, "Creator" : creatorName!, "CreatorID": creatorID!, "Version": "0", "Pins": []] as [String : Any]
                        
                        // Stores the pack details (JSON file) to local storage via the LocalStorageHandler class inside the logged in user's folder
                        let storageHandler = LocalStorageHandler(fileName: fileName!, subDirectory: "UserID-\(creatorID!)-Packs", directory: .documentDirectory)
                        if storageHandler.addNewPackToPhone(packData: jsonToWrite as NSDictionary){
                            // If storage was successful then the 'successful' alert details are prepared
                            alertTitle = "Thank You"
                            alertMessage = "Pack Successfully Created"
                            isNewPackRegistered = true
                        } else{ // If storage was unsuccessful then the 'unsuccessful' alert details are prepared
                            alertTitle = "ERROR"
                            alertMessage = "Couldn't Save Register Pack"
                        }
                    }
                    // Returns the execution flow to the main thread
                    DispatchQueue.main.async(execute: {
                        // Displays a message to the user indicating the successful/unsuccessful creation of a new pack
                        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            // Checks if pack was successfully created
                            if isNewPackRegistered{
                                self.dismiss(animated: true, completion: nil) // Exits registration page
                                // Lets the pack selector know that the form has been dismissed
                                ModalTransitionMediator.instance.sendModalViewDismissed(modelChanged: true)
                            }}))
                        self.present(alertCon, animated: true, completion: nil)
                    })
                }
            }
        }else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the createPackButtonTapped function until internet connectivity is restored
                self.createPackButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }
    
    // Connects the cancel button to the code
    // - Dismisses registration form when tapped
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
