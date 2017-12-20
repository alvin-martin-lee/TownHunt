//
//  PinPackMapViewController.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the pin pack map view parent class

import MapKit // UIKit constructs and manages the app's UI

// Class defines two methods which are used by both map view screens
class PinPackMapViewController: UIViewController {
    
    // Returns an array of Pin Location objects from a list of pin data
    func getListOfPinLocations(packData: [String: Any]) -> [PinLocation] {
        // Extracts the pins from the pack data
        let packDetailPinList = packData["Pins"] as! [[String:String]]
        // Initiates PinLocation array
        var gamePins: [PinLocation] = []
        // Checks if there are any pins in the pack
        if packDetailPinList.isEmpty {
            print(packDetailPinList)
            print("No Pins in pack")
        } else{ // If there are pins then each pin in the pack is converted to a PinLocation and appended to the gamePins array
            print("There are pins in the loaded pack")
            for pin in packDetailPinList{
                let pinToAdd = PinLocation(title: pin["Title"]!, hint: pin["Hint"]!, codeword: pin["Codeword"]!, coordinate: CLLocationCoordinate2D(latitude: Double(pin["CoordLatitude"]!)!, longitude: Double(pin["CoordLongitude"]!)!), pointVal: Int(pin["PointValue"]!)!)
                gamePins.append(pinToAdd)
            }
        } // List of PinLocations are returned
        return gamePins
    }
    
    // Returns all of the pack data loaded from local storage
    func loadPackFromFile(filename: String, userPackDictName: String, selectedPackKey: String, userID: String) -> [String : AnyObject]{
        // Initialises pack data array
        var packData: [String : AnyObject] = [:]
        // Initialises a localStorageHandler object
        let localStorageHandler = LocalStorageHandler(fileName: filename, subDirectory: "UserID-\(userID)-Packs", directory: .documentDirectory)
        // Retrieves JSON data
        let retrievedJSON = localStorageHandler.retrieveJSONData()
        // Converts JSON data into an editable dictionary
        packData = retrievedJSON as! [String : AnyObject]
        return packData // JSON data returned
    }
}
