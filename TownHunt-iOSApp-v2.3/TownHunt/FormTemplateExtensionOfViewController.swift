//
//  FormTemplateExtensionOfViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the form view parent class

import UIKit // UIKit constructs and manages the app's UI

// Class provides additional methods relating to view with forms
class FormTemplateExtensionOfViewController: UIViewController {

    // Called when the view controller first loads. This method sets up the view
    override func viewDidLoad() {
        // Creates the view
        super.viewDidLoad()
        
        // Adds an event listener to the view that will shift the view upwards when the keyboard is displayed on screen
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Adds an event listener to the view which looks out for taps on the view. If the user taps the view (not the keyboard)
        // and an onscreen keyboard is displayed, the onscreen keyboard will disappear
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Adds an event listener to the view that will re-centre the view when the keyboard is dismissed from the screen screen
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Method which dismisses the keyboard from the screen
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Method which shifts the view upwards by 150 pixels
    func keyboardWillShow(sender: NSNotification){
        self.view.frame.origin.y = -150
    }
    
    // Method which sets the view in its original position
    func keyboardWillHide(sender: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    // Method which sees if a test string matches a regular expression pattern
    private func stringTester(regExPattern: String, testString: String) -> Bool {
        let stringTester = NSPredicate(format:"SELF MATCHES %@", regExPattern)
        return stringTester.evaluate(with: testString)
    }
    
    // Method which returns whether the test string is a valid email address
    func isEmailValid(testStr:String) -> Bool {
        let emailRegExPattern = "^[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\\.[A-Za-z]{2,}"
        return stringTester(regExPattern: emailRegExPattern, testString: testStr)
    }
    
    // Method which returns whether the test string only contains alphanumeric characters
    func isAlphanumeric(testStr:String) -> Bool {
        let alphanumericRegExPattern = "^[A-Za-z0-9]+$"
        return stringTester(regExPattern: alphanumericRegExPattern, testString: testStr)
    }

}
