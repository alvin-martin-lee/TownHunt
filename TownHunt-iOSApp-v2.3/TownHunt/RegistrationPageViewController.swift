//
//  RegistrationPageViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the behaviour of the new account registration form

import UIKit // UIKit constructs and manages the app's UI

// Class controls the functionality of the new account registration view
class RegistrationPageViewController: FormTemplateExtensionOfViewController {

    // Outlets connect UI elements to the code, thus making UI login textfield elements accessible programmatically
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatPassWordTextField: UITextField!
    
    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Sets the background image
        setBackgroundImage(imageName: "registrationBackgroundImage")
    }
    
    // Connects the register button to the code
    // - Validates the new account details and sends it to the database API
    @IBAction func registerButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            // Retrieves the user input
            let username = usernameTextField.text
            let userEmail = userEmailTextField.text
            let userPassword = userPasswordTextField.text
            let userRepeatPassword = userRepeatPassWordTextField.text
            
            // Check for empty fields
            if((username?.isEmpty)! || (userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)!) {
                // Display data entry error message
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
                
            // Checks if email is a valid email address
            } else if !isEmailValid(testStr: userEmail!){
                // Display email invalid error message
                displayAlertMessage(alertTitle: "Email Invalid", alertMessage: "Please enter a valid email")
                
            // Checks if username only contains alphanumeric characters
            } else if !isAlphanumeric(testStr: username!){
                // Display username invalid error message
                displayAlertMessage(alertTitle: "Username Invalid", alertMessage: "Username must only contain alphanumeric characters")
                
            // Checks if username character length is greater than 20
            } else if((username?.characters.count)! > 20){
                //Displays username character length error message
                displayAlertMessage(alertTitle: "Username is Greater Than 20 Characters", alertMessage: "Please enter a username which is less than or equal to 20 characters")
                
            // Checks if passwords are the same
            } else if(userPassword != userRepeatPassword){
                //Displays non-matching passwords error message
                displayAlertMessage(alertTitle: "Passwords Do Not Match", alertMessage: "Please enter matching passwords")

            } else { // User input meets the standards
                // A post string is posted to the online database API via the DatabaseInteraction class on the background thread
                // The "registerUser.php" API checks if the user already exists in the online database, if not then the user is added to the database
                let responseJSON = dbInteraction.postToDatabase(apiName: "registerUser.php", postData: "username=\(username!)&userEmail=\(userEmail!)&userPassword=\(userPassword!)"){ (dbResponse: NSDictionary) in
                
                    // Initialises the error message variables and isUserRegistered flag
                    var alertTitle = "ERROR"
                    var alertMessage = "JSON File Invalid"
                    var isUserRegistered = false
                    
                    // Checks if there is a database error indicating that the new user couldn't be added to the database
                    if dbResponse["error"]! as! Bool{
                        // Prepares 'unsuccessful' alert title and message
                        alertTitle = "ERROR"
                        alertMessage = dbResponse["message"]! as! String
                    // Checks if there wasn't a database error indicating that the new user was added to the database
                    } else if !(dbResponse["error"]! as! Bool){
                        // Prepares 'successful' alert title and message
                        alertTitle = "Thank You"
                        alertMessage = dbResponse["message"]! as! String
                        isUserRegistered = true // Changes isUserRegistered flag
                    }
                    
                    // Returns the execution flow to the main thread
                    DispatchQueue.main.async(execute: {
                        // Displays an alert to the user about the attempted user registration 
                        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            // Checks if the user is registered flag
                            if isUserRegistered{
                                // Registration form is dismisses/exited
                                self.dismiss(animated: true, completion: nil)
                            }}))
                        self.present(alertCon, animated: true, completion: nil)
                    })
                }
            }
        }else{ // If no internet connectivity, an error message is displayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the registerButtonTapped function until internet connectivity is restored
                self.registerButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    // Connects the 'I Already Have An Account' button to the code
    // - Dismisses the view when tapped
    @IBAction func alreadyHaveAccountButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
