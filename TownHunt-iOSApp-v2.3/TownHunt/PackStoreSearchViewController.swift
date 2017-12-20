//
//  PackSearchViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic of the pack store search

import UIKit // UIKit constructs and manages the app's UI

// Class controls the pack store search view
class PackStoreSearchViewController: FormTemplateExtensionOfViewController {
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
        // Search textfields
    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var creatorTextField: UITextField!
    
    // Attribute containing the search string
    public var searchDataToPost = ""
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Sets the background image
        setBackgroundImage(imageName: "packStoreSearchBackground")
    }

    // Called when 'Pack You Have Made' button tapped
    // - Sets the text fields as empty except the creator text field which is set to the username of the logged in user
    private func prepareSearchForCreatorsPack(){
        packNameTextField.text = ""
        locationTextField.text = ""
        creatorTextField.text = UserDefaults.standard.string(forKey: "Username") // Retrieves the username of the logged in user
        prepareSearchDataToPost() // Prepares the search string
    }
    
    // Generates the search string/data which will be posted to the online database (API)
    private func prepareSearchDataToPost(){
        // Retrieves user input
        let packNameFrag = packNameTextField.text! // Pack name search fragment
        let locationFrag = locationTextField.text! // Location search fragment
        let creatorUsernameFrag = creatorTextField.text! // Creator username search fragment
        // Generates the search string/data
        searchDataToPost = "usernameFragment=\(creatorUsernameFrag)&packNameFragment=\(packNameFrag)&locationFragment=\(locationFrag)"
    }
    
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks if the segue destination view controller is a Navigation controller
        if let destNavCon = segue.destination as? UINavigationController{
            // Checks if the target view controller is the pin pack store table view
            if let targetController = destNavCon.topViewController as? PackStoreListTableViewController {
                // Checks that the segue identifier is "PackSearchToCreatorsPacksTable"
                if segue.identifier == "PackSearchToCreatorsPacksTable"{
                    prepareSearchForCreatorsPack()
                // Checks that the segue identifier is "PackSearchToSearchResultsPacksTable"
                } else if segue.identifier == "PackSearchToSearchResultsPacksTable"{
                    prepareSearchDataToPost()
                }
                // Passes the search string to the pack store table view
                targetController.searchDataToPost = self.searchDataToPost
            }
        }
    }
    
    // Connects the back button to the code
    // - Dismisses the pack store search view when tapped
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
