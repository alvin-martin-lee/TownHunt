//
//  PinStoreHomeViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic of the pack store home

import UIKit // UIKit constructs and manages the app's UI

// Class controls the behaviour of the pack store home view
class PackStoreHomeViewController: UIViewController {
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem! // The menu button
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()

        // Sets the background image
        setBackgroundImage(imageName: "packStoreHomeBackground")
        
        // Connects the menu button to the menu screen
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
    }
        
    // System function which is called when the view is about to transition (segue) to another view. This enables data to be passes between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checks that the segue identifier is "PackStoreHomeToLocalTableList"
        if segue.identifier == "PackStoreHomeToLocalTableList"{
            // Checks if the segue destination view controller is a Navigation controller
            if let navigationController = segue.destination as? UINavigationController{
                // Checks if the target view controller is the pin pack store table view
                if let nextViewController = navigationController.topViewController as? PackStoreListTableViewController{
                    nextViewController.loadLocalPacksFlag = true // Sets the table view's load local packs flag as true
                    navigationController.title = "List of Local Packs" // Changes the title of the table view
                }
            }
        }
    }
}
