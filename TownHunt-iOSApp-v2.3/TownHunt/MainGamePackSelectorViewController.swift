//
//  MainGamePackSelectorViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the pack selector view

import UIKit // UIKit constructs and manages the app's UI

// Class acts as the logic behind the  pack selector view
class MainGamePackSelectorViewController: FormTemplateExtensionOfViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // This view's optional delegate is specified as of the MainGameModalDelegate class
    var delegate: MainGameModalDelegate?
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var packPicker: UIPickerView! // The slot-machine-esque selector which displays all of the local packs
    @IBOutlet weak var gameTypeSegCon: UISegmentedControl! // The game type binary (segmented) selector
    @IBOutlet weak var selectMapButton: UIButton! // The 'Select Map' button
    @IBOutlet weak var viewLeaderboardButton: UIButton! // The 'View Leaderboard' button
    
    // Initialises attributes which will hold details about all local packs, selected pack and pack options
    private var allPacksDict = [String: String]() // Holds the pack name-location key and the creator user ID of all local packs
    private var pickerData = [String]() // Stores data (pack name-location keys) which will be shown in the picker
    private var selectedPickerData: String = "" // Holds the selected picker data (pack name-location key)
    private var gameType = "competitive" // Stores which game type is selected
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()

        // Sets the background image 
        setBackgroundImage(imageName: "packSelectorBackground")
        
        // Sets up the pack picker
        self.packPicker.delegate = self // Gives this current class the ability to control the picker UI element
        self.packPicker.dataSource = self // The data source of the picker is set as this current class
        setUpPicker() // Calls a function to the set up the picker
    }
    
    // [------------------------------ Pack Picker Mechanics -------------------------------------------------------]
    
    // Populates the picker with the names of local packs
    private func setUpPicker(){
        let defaults = UserDefaults.standard
        // Retrieves the list of user ids whose packs are found in local storage
        let listOfUsersOnPhone = defaults.array(forKey: "listOfLocalUserIDs")
        // Checks if there is no users whose packs are on the phone
        if !(listOfUsersOnPhone!.isEmpty){
            // Iterates over every id and retrieves all packs on the phone
            for userID in listOfUsersOnPhone as! [String]{
                let userPackDictName = "UserID-\(userID)-Packs"
                // Checks that the user has packs on the phone
                if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName) {
                    // Appends all pack name-location keys and their creator user id to the allPacksDict
                    for pack in Array(dictOfPacksOnPhone.keys){
                        self.allPacksDict[pack] = userID
                    }
                }
            }
            // Sorts the picker data in alphabetical order by the pack name-location key
            self.pickerData = Array(allPacksDict.keys).sorted{ $0.lowercased() < $1.lowercased() }
            // Sets the initial selected element as the first value of the picker
            self.selectedPickerData = pickerData[0]
            
        // If there are no local packs, pack interaction buttons are hidden and a message is shown to the user
        } else if pickerData.isEmpty {
            // The only value in the picker is set to "No Packs Found"
            self.pickerData = ["No Packs Found"]
            self.selectMapButton.isHidden = true // User is unable to select a pack as there aren't any
            self.viewLeaderboardButton.isHidden = true // Leaderboard button is hidden as there are no packs
        }
    }
    
    // PickerView method which sets the number of columns of data in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // The picker used in the app only has one column to display the pack name-location key
        return 1
    }
    
    // PickerView method which sets the number of rows of data in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Number of rows is determined by the number of elements in the pickerData array
        return self.pickerData.count
    }
    
    // PickerView method which sets the picker data to display for a certain row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Returns the corresponding pack name-location key
        return self.pickerData[row]
    }
    
    // PickerView method that retrieves the item that is currently selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // "selectedPickerData" is set to the pack name-location key
        self.selectedPickerData = pickerData[row]
    }
    
    // PickerView method that sets up how the text of each row should be
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // Instantiates a label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 330, height: 30));
        label.lineBreakMode = .byWordWrapping; // Text won't go off the screen and instead wrap
        label.numberOfLines = 0 // Allows the label to have unlimited lines
        label.text = pickerData[row] // Sets the text to display as the pack name-location key
        label.textColor = UIColor.white // Sets the text colour to white
        label.font = UIFont.systemFont(ofSize: CGFloat(20)) // Sets the font to 20 pixels
        label.sizeToFit() // Makes the frame of the label fit the size of the text
        return label // Returns the label to display
    }
    
    // PickerView method that sets the height of each row
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50 // 50 pixels is returned
    }
    
    // Connects the Select Pack Button to the code
    // - If the select button is tapped then the view is dismissed and the selected pack data is returned to the main game view
    @IBAction func selectPackButtonTapped(_ sender: Any) {
        // Checks to see if this view has a delegate
        if let delegate = self.delegate {
            // Passes the selected pac data to the main game view
            delegate.packSelectedHandler(selectedPackKey: self.selectedPickerData, packCreatorID: self.allPacksDict[self.selectedPickerData]!, gameType: gameType)
            // Dismisses the pack selector view
            self.dismiss(animated: true, completion: nil)
        } else{ // Displays error message
            displayAlertMessage(alertTitle: "Error", alertMessage: "Pack Selector has no Delegate")
        }
        
    }
    
    // [ --------------------- Game Type Selector Mechanics -----------------------------]
    
    // Connects the game type selector to the code
    // - Changes the gameType attribute
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        // A binary switch changes the game type from competitive to casual depending on what the user has selected
        switch gameTypeSegCon.selectedSegmentIndex
        {
        case 0:
            gameType = "competitive"
        case 1:
            gameType = "casual"
        default:
            break
        }
    }
    
    // [----------------------------System Mechanics-----------------------------------------]
    
    // Connects the game type info button to the code
    // - Display info explaining what the two game modes are
    @IBAction func tapForInfoButtonTapped(_ sender: Any) {
        let displayMessage = "Competitive mode: 5 Pins will be initially appear with more and more pins being added as the game progresses. You will have to hunt for the pins under a time limit. \n\nCasual mode: All of the pins in the pack will appear. Hunt them all in your own time with no time limit. \n\nYour first competitive playthrough score will be added to the leaderboard. If your first playthrough was casual, no future scores for that pack will count in the leaderboard"
        displayAlertMessage(alertTitle: "Competitive or Casual?", alertMessage: displayMessage)
        
    }
    
    // Connects the cancel button to the code
    // - Closes the view when the cancel button is pressed
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks that the segue identifier is "PackSelectorToLeaderboard" 
        if segue.identifier == "PackSelectorToLeaderboard" {
            // Retrieves the navigation controller of the target view
            let destNavCon = segue.destination as! UINavigationController
            // Checks that the target controller is of the class LeaderboardViewController
            if let targetController = destNavCon.topViewController as? LeaderboardViewController{
                // Passes selected pack data to the leaderboard view
                targetController.selectedPackKey = self.selectedPickerData // Pack name-location key
                targetController.packCreatorID = self.allPacksDict[self.selectedPickerData]! // Pack creator id
            }
        }
    }
}
