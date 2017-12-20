//
//  AccountInfoPageViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the Account Info Page

import UIKit // UIKit constructs and manages the app's UI

// This class controls the logic behind the account info page view
class AccountInfoPageViewController: UIViewController, ModalTransitionListener {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem! // Menu button on the nav bar
    @IBOutlet weak var userIDInfoLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailInfoLabel: UILabel!
    @IBOutlet weak var noPacksPlayedInfoLabel: UILabel! // Number of packs played by the user
    @IBOutlet weak var noPacksCreatedInfoLabel: UILabel! // Number of packs created by the user
    @IBOutlet weak var totCompPointsLabel: UILabel! // Total number of 'competitive' points scored by the user
    
    // Initialises attributes relating to the stats of the logged in user
    private var noPacksPlayed = 0
    private var noPacksCreated = 0
    private var totCompPoints = 0
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Singleton which sets up an event listener (listening for the login page to be dismissed) in this instance of the class
        ModalTransitionMediator.instance.setListener(listener: self)
        
        // Connects the menu button to the menu screen
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Sets the background image
        setBackgroundImage(imageName: "accountInfoBackgroundImage")
        
        // Initiates the process of retrieving the user stats from the database
        loadAccountDetails()
    }
    
    // [------------------ Retrieving and Displaying the Account Info ---------------------]
    
    // Retrieves the user stats from the database via the API
    private func getDBAccountStats(userID: String){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            // A post string is posted to the online database API via the DatabaseInteraction class on the background thread
            // The "getAccountStats.php" API queries the online database for the user stats and returns the information
            let responseJSON = dbInteraction.postToDatabase(apiName: "getAccountStats.php", postData: "userID=\(userID)"){ (dbResponse: NSDictionary) in
                
                // The local user stats variables are updated
                self.noPacksPlayed = Int(dbResponse["totalNumPacksPlayed"]! as! String)!
                self.noPacksCreated = Int(dbResponse["totalNumPacksCreated"]! as! String)!
                self.totCompPoints = Int(dbResponse["totalNumCompPoints"]! as! String)!
                
                // Returns the execution flow to the main thread
                DispatchQueue.main.async(execute: {
                    // The UI labels are updated to show the retrieved stats
                    self.noPacksPlayedInfoLabel.text = "No Of Packs Played: \(self.noPacksPlayed)"
                    self.noPacksCreatedInfoLabel.text = "No Of Packs Created: \(self.noPacksCreated)"
                    self.totCompPointsLabel.text = "Total Competitive Points: \(self.totCompPoints)"
                })
            }
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the getDBAccountStats function until internet connectivity is restored
                self.getDBAccountStats(userID: userID)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }

    // Method which loads the user details
    private func loadAccountDetails(){
        
        // Retreives the user details stored locally
        let userID = UserDefaults.standard.string(forKey: "UserID")!
        let username = UserDefaults.standard.string(forKey: "Username")!
        let userEmail = UserDefaults.standard.string(forKey: "UserEmail")!
        // Updates the UI labels
        userIDInfoLabel.text = "User ID: \(userID)"
        usernameInfoLabel.text = "Username: \(username)"
        emailInfoLabel.text = "Email: \(userEmail)"
        // Initiates the retrieval of the user stats found on the database
        getDBAccountStats(userID: userID) // Passes the user id
    }
    
    // Connects the logout button to the code
    // - Carries out the logout process i.e. Removes all information about the logged in user
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn") // Changes flag
        // Removes account information
        UserDefaults.standard.removeObject(forKey: "UserID")
        UserDefaults.standard.removeObject(forKey: "Username")
        UserDefaults.standard.removeObject(forKey: "UserEmail")
        UserDefaults.standard.synchronize() // Commits the changes to the userdefaults database
        // Transitions from the account info page to the login page
        self.performSegue(withIdentifier: "loginViewAfterLogout", sender: self)
        
    }
    
    // ModalTransitionalListener protocol function which is called when the presented view (login page) is dismissed
    func modalViewDismissed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.loadAccountDetails() // Reloads the UI labels with information about the newly logged in user
    }
}
