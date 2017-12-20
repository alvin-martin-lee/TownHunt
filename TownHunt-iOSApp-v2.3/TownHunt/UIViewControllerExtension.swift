//
//  UIViewControllerExtension.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file extends the UIViewController class with an additional two methods

extension UIViewController {
    
    // Method sets the background image of the view.
    // - The name of the image (found in the 'Assets' folder) is passed into this function
    func setBackgroundImage(imageName: String){
        // Creates a temp image frame/context - the size of the image matches the size of the view/screen
        UIGraphicsBeginImageContext(self.view.frame.size)
        // The image is retrieved from the 'Assets' folder and is loaded into the temp image frame
        UIImage(named: imageName)?.draw(in: self.view.bounds)
        // Copies the temp image frame into the constant 'backgroundImage'
        let backgroundImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // Deletes the temp image frame
        UIGraphicsEndImageContext()
        // Sets the view background image
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
    }
    
    // Function displays a generic alert with an OK button that just dismisses the alert
    // - Takes in an alert title and message that will be displayed
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
}
