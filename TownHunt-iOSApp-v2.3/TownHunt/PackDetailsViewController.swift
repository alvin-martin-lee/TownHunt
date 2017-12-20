//
//  PackDetailsViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the pack details view controller

import UIKit // UIKit constructs and manages the app's UI

// Class controls the Pack Details View
class PackDetailsViewController: FormTemplateExtensionOfViewController {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
        // All are outlets displaying information about the pack
    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var briefDescriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var timeControlStepper: UIStepper!
    @IBOutlet weak var gameTimeTextLabel: UILabel!
    @IBOutlet weak var gameTimeStaticLabel: UILabel!
        // Connects the back and edit detail button
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editDetailButton: UIButton!
    
    // Initialises public attributes
    public var isPackDetailsEditable = true // Is Editable? flag
    public var packDetails = [:] as [String: String] // Holds the pack details
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Sets the background image
        setBackgroundImage(imageName: "packDetailsBackground")
        
        // Sets the initial game type label value
        timeStepperAction(Any.self)
        // Sets up the form labels with the pack details
        setUpForm()
        
        // Checks if the is editable flag is false
        if isPackDetailsEditable == false{
            // Pack become uneditable as the edit detail button is hidden
            editDetailButton.isHidden = true
        }
    }
    
    // Updates the game time label with the current value of the stepper
    @IBAction func timeStepperAction(_ sender: Any) {
        gameTimeTextLabel.text = "Game Time: \(Int(timeControlStepper.value)) mins"
    }
    
    // Displays the pack details to the user via the UI outlets
    private func setUpForm(){
        changeFormEnabledStatus() // Disables the ability to edit the textfields
        // Sets pack detail labels
        packNameTextField.text = packDetails["PackName"]!
        briefDescriptionTextField.text = packDetails["Description"]!
        locationTextField.text = packDetails["Location"]!
        let timeLimit = packDetails["TimeLimit"]!
        // Two game time labels for aesthetic reasons, one is shifted to the left when the stepper is added to the form
        gameTimeTextLabel.text = "Game Time: \(timeLimit) mins"
        gameTimeStaticLabel.text = "Game Time: \(timeLimit) mins"
        timeControlStepper.value = Double(Int(timeLimit)!) // Sets the value of the stepper
        backButton.isHidden = false
    }
    
    // Changes the fields from being disabled (user-uneditable) to enabled (user-editable) and vice versa
    private func changeFormEnabledStatus(){
        // Enables/Disables the pack description and pack location from being edited
        briefDescriptionTextField.isUserInteractionEnabled = !briefDescriptionTextField.isUserInteractionEnabled
        locationTextField.isUserInteractionEnabled = !locationTextField.isUserInteractionEnabled
        // Hides/Unhides the game time stepper as associated label
        timeControlStepper.isHidden = !timeControlStepper.isHidden
        gameTimeTextLabel.isHidden = !gameTimeTextLabel.isHidden
        backButton.isHidden = !backButton.isHidden
    }
    
    // Updates pack details with the new data provided by the user
    private func updatePackDetailDict(){
        // Retrieves user input
        let packDescrip = briefDescriptionTextField.text!
        let packLocation = locationTextField.text!
        let gameTime = String(Int(timeControlStepper.value))
        
        // Changes the pack details array to reflect the updated pack details values
        packDetails["Description"] = packDescrip
        packDetails["Location"] = packLocation
        packDetails["TimeLimit"] = gameTime
    }

    // Enables/Disables the pack details to be edited
    @IBAction func editDetailButtonTapped(_ sender: Any) {
        // Checks which 'mode' the view is in
        if editDetailButton.title(for: UIControlState()) == "Edit Details"{
            // Alert displayed to user indicating that only the pack description and game time can be edited
            displayAlertMessage(alertTitle: "Editing Pack", alertMessage: "Only the description and game time can be edited")
            gameTimeStaticLabel.text = ""
            editDetailButton.setTitle("Done", for: UIControlState()) // Sets the edit details button's text to 'Done'
            changeFormEnabledStatus() // Changes fields to enable editing
        } else{ // User has finished editing
            //Checks the character length of the pack description
            if((briefDescriptionTextField.text!.characters.count) > 30){
                //Displays pack description character length error message
                displayAlertMessage(alertTitle: "Pack Description is Greater Than 30 Characters", alertMessage: "Please enter a description which is less than or equal to 30 characters")
            }else{
                gameTimeStaticLabel.text = gameTimeTextLabel.text
                editDetailButton.setTitle("Edit Details", for: UIControlState()) // Sets the edit details button's text to 'Edit Details'
                changeFormEnabledStatus() // Changes fields to disable editing
            }
        }
    }
    
    // Connects the back button to the code
    // - Dismisses the pack details view and returns the (updated) back to the view that presented the pack details view
    @IBAction func backButtonTapped(_ sender: Any) {
        updatePackDetailDict() // Updates the pack details to reflect the user input
        // Checks if the presenting view controller was a navigation controller
        if let destNavCon = presentingViewController as? UINavigationController{
            // Checks if the final destination view controller is the pin pack editor
            if let targetController = destNavCon.topViewController as? PinPackEditorViewController{
                // Passes the pack details back to the pin pack editor
                for key in Array(packDetails.keys){
                    targetController.packData[key] = packDetails[key]! as AnyObject?
                }
            }
        }
        // Dismisses the pack details view controller
        self.dismiss(animated: true, completion: nil)
    }
}
