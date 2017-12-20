//
//  PinListInPackTableViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the pin list table view

import UIKit // UIKit constructs and manages the app's UI

// Class controls the PinListInPackTable View
class PinListInPackTableViewController: UITableViewController {
    
    // Initialises attributes which will hold the list of pack pins
    public var listOfPins: [PinLocation]! = []
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        listOfPins = listOfPins.sorted{ ($0.title)!.lowercased() < ($1.title)!.lowercased() }
    }

    // TableView method that sets the number of columns in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // TableView method that sets the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in the table is the same as the number of pins in the pack
        return listOfPins.count
    }
    
    // TableView method which defines what to display in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> PinCell {
        // Returns a reusable table-view cell object based on the prototype cell defined in the UI storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinCell
       
        // Sets up the label in the cell with information about each record
        let pin = listOfPins[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = pin.title
        cell.hintLabel.text = pin.hint
        cell.codewordLabel.text = "Answer: \(pin.codeword)"
        cell.pointValLabel.text = "(\(String(pin.pointVal)) Points)"
        return cell
    }
    
    // TableView method which is called when a row, in the table, is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieves the associated pin
        let selectedPin = listOfPins[indexPath.row]
        // Presents the user with an alert with the details of the pin and the option to delete the pin
        let alertCon = UIAlertController(title: selectedPin.title, message: "Hint: \(selectedPin.hint)\n\nAbout: \(selectedPin.codeword)\n\nPoints: \(String(selectedPin.pointVal))", preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            self.deletePin(indexPath: indexPath) // Deletes the pin
        }))
        alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
    // TableView Method which enables each tow in the table to be slid left
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Checks if the user clicked on the delete button after sliding the row to the left
        if editingStyle == UITableViewCellEditingStyle.delete {
            deletePin(indexPath: indexPath) // Deletes the pin
        }
    }
    
    // Method which deletes the pin from the pack pins array and the table
    private func deletePin(indexPath: IndexPath){
        listOfPins.remove(at: (indexPath as NSIndexPath).row) // Removes pin from pack pins array
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic) // Removes pin form table
    }
    
    // Connects the Done button to the code
    @IBAction func doneButtonNav(_ sender: AnyObject) {
        // Checks if the presenting view controller was a navigation controller
        if let destNavCon = presentingViewController as? UINavigationController{
            // Checks if the final destination view controller is the pin pack editor
            if let targetController = destNavCon.topViewController as? PinPackEditorViewController{
                // Passes the pack pins back to the pin pack editor
                targetController.gamePins = listOfPins
            }
        }
        // Notifies the pin pack editor that the pin list view has been dismissed
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil) // Dismisses the pin list view
    }
    
    // Connects the help button to the code
    // - Displays in info alert about the pin list view
    @IBAction func helpButtonTapped(_ sender: Any) {
        displayAlertMessage(alertTitle: "Help", alertMessage: "Here is a list of all the pins in the pack. Swipe left on a pin and tap delete to remove the pin from the pack. Tap a pin to find out more information about the pin. There is an option to delete the pin here as well.\n\nOnce you are finished, tap 'Done' to return to the map.")
    }
}
