//
//  FirstLoadSetup.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the initial app setup when the app launches for the first time

import UIKit // UIKit constructs and manages the app's UI

class FirstLoadSetup {
    
    // Method is called when the app launches for the first time
    func initialSetup(){
        
        // Initialises the list of IDs of all the users whose packs are found on the device
        UserDefaults.standard.setValue([String](), forKey:"listOfLocalUserIDs")
        // Changes the need initial setup flag
        UserDefaults.standard.set(false, forKey: "isInitialSetupRequired")
        // Commits the changes, to the pack linked list information and isInitialSetupRequired, to the local userdefaults database
        UserDefaults.standard.synchronize()

    }
}
