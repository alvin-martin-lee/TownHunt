//
//  LoginPageViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the login page

import UIKit // UIKit constructs and manages the app's UI

// Class defines the logic of the login view
class LoginPageViewController: FormTemplateExtensionOfViewController {
    
    // Outlets connect UI elements to the code, thus making UI login textfield elements accessible programmatically
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Sets the background image
        setBackgroundImage(imageName: "loginBackgroundImage")

    }
    
    // Connects the login button to the code
    // - Checks if the user and password exists in the database. If the user is found the user details are stored locally
    @IBAction func loginButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // Retrieves user input for the email and password
            let userEmail = userEmailTextField.text
            let userPassword = userPasswordTextField.text
        
            // Checks that the user has entered an email and the password
            if((userEmail?.isEmpty)! || (userPassword?.isEmpty)!) {
                // Display error message
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
                
            // Checks if the email address entered is a valid email address
            } else if !isEmailValid(testStr: userEmail!){
                // Display error message
                displayAlertMessage(alertTitle: "Email Invalid", alertMessage: "Please enter a valid email")
                
            } else {
                // A post string is posted to the online database API via the DatabaseInteraction class on the background thread
                // The "loginUser.php" API checks if the user and password exists in the online database
                let responseJSON = dbInteraction.postToDatabase(apiName: "loginUser.php", postData: "userEmail=\(userEmail!)&userPassword=\(userPassword!)"){ (dbResponse: NSDictionary) in
                    
                    // Initialises the error message variables and isAccountFound flag
                    var alertTitle = "ERROR"
                    var alertMessage = "JSON File Invalid"
                    var isAccountFound = false
                    
                    // Checks if there is a database error indicating that the username and or password was incorrect
                    if dbResponse["error"]! as! Bool{
                        // Prepares 'unsuccessful' alert title and message
                        alertTitle = "ERROR"
                        alertMessage = dbResponse["message"]! as! String
                    // Checks if there were no errors indicating that the username and password combination was correct
                    } else if !(dbResponse["error"]! as! Bool){
                        // Prepares 'successful' alert title and message
                        alertTitle = "Thank You"
                        alertMessage = "Successfully Logged In"
                        
                        // Sets the isAccountFound flag to true
                        isAccountFound = true
                        
                        // Retrieves the account information from the database response
                        let accountDetails = dbResponse["accountInfo"]! as! NSDictionary
                        // Updates local logged in user info
                        UserDefaults.standard.set(true, forKey: "isUserLoggedIn") // Is a user logged in flag is set to true
                        UserDefaults.standard.set(accountDetails["UserID"]! as! String, forKey: "UserID") // Logged in user ID is stored
                        UserDefaults.standard.set(accountDetails["Username"]! as! String, forKey: "Username") // Logged in username is stored
                        UserDefaults.standard.set(accountDetails["Email"]! as! String, forKey: "UserEmail") // Logged in user email is stored
                        UserDefaults.standard.synchronize() // Commits the user information to the local userdefaults database
                    }
                    
                    // Returns the execution flow to the main thread
                    DispatchQueue.main.async(execute: {
                        // Displays an alert to the user about the attempted log in
                        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            // Checks if the user account was found
                            if isAccountFound{
                                // If the account is logged in then the login view is dismissed
                                self.dismiss(animated: true, completion: nil)
                                // The presenting view is notified that the login view has been dismissed
                                ModalTransitionMediator.instance.sendModalViewDismissed(modelChanged: true)
                            }}))
                        self.present(alertCon, animated: true, completion: nil)
                    })
                }
            }
        }else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the loginButtonTapped function until internet connectivity is restored
                self.loginButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }

}
