//
//  PinPackCreatorInitViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the pick pack creator initial home screen

import UIKit // UIKit constructs and manages the app's UI

// Class controls the UI elements and logic of the pack creator initial screen
class PinPackCreatorInitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ModalTransitionListener {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem! // Menu button on the nav bar
    // The slot-machine-esque selector which displays all of the local packs made by the logged in user
    @IBOutlet weak var packPicker: UIPickerView!
    
    // Initialises attributes relating to the local packs created by the logged in user stored on the phone
    private var pickerData: [String] = [String]() // Stores the data that will populate the picker
    private var userPackDictName = "" // Internal dictionary holding the filenames of the local packs created by the user
    private var selectedPickerData: String = ""
    private var userID = ""
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Singleton which sets up an event listener (listening for the new pin pack registration form 
        // to be dismissed) in this instance of the class
        ModalTransitionMediator.instance.setListener(listener: self)

        // Connects the menu button to the menu screen
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Sets the background image
        setBackgroundImage(imageName: "createPackBackground")
        
        // Sets up the pack picker
        self.packPicker.delegate = self // Gives this current class the ability to control the picker UI element
        self.packPicker.dataSource = self // The data source of the picker is set as this current class
        setUpPicker() // Calls a function to the set up the picker
    }
    
    // Populates the picker with the names of local packs made by the logged in user
    private func setUpPicker(){
        let defaults = UserDefaults.standard
        userID = defaults.string(forKey: "UserID")! // Retrieves logged in user's id
        userPackDictName = "UserID-\(userID)-Packs"
        // Checks that the dictionary which contains the local packs made by the user exists
        // If this doesn't exist than no local packs made by the user exists
        if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName) {
            // Sets the picker display data as the pack name-location key, sorted alphabetically 
            self.pickerData = Array(dictOfPacksOnPhone.keys).sorted{ $0.lowercased() < $1.lowercased() }
            // Sets the initial selected element as the first value of the picker
            self.selectedPickerData = pickerData[0]
            self.selectButton.isHidden = false // User is able to select a pack as there aren't any
        // If there are no local packs, pack selector button is hidden and a message is shown to the user
        } else {
            // The only value in the picker is set to "No Packs Found"
            self.pickerData = ["No Packs Found"]
            self.selectButton.isHidden = true // User is unable to select a pack as there aren't any
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
    
    // ModalTransitionalListener protocol function which is called when the presented view (new pack registration page) is dismissed
    func modalViewDismissed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.setUpPicker() // Retrieves the local packs created by the user including the newly registered pack
        self.packPicker.reloadAllComponents() // Reloads the picker display
    }
    
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks that the segue identifier is "PackSelectorToPackEditor"
        if segue.identifier == "PackSelectorToPackEditor"{
            // Checks if the segue destination view controller is a Navigation controller
            if let navigationController = segue.destination as? UINavigationController{
                // Checks if the target view controller is the pin pack editor
                if let nextViewController = navigationController.topViewController as? PinPackEditorViewController{
                    // Data passed
                    nextViewController.selectedPackKey = self.selectedPickerData // Pack name-location key
                    nextViewController.userPackDictName = self.userPackDictName // User packs dictionary name
                    nextViewController.userID = self.userID // User id
                }
            }
        }
    }

}
