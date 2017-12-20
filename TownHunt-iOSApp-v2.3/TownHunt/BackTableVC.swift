//
//  BackTableVC.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the app's menu back table

import UIKit // UIKit constructs and manages the app's UI

// Class controls the app's menu
class BackTableVC: UITableViewController{
    
    // List of options in the app
    var menuOptions: [String] = ["Main Map", "Pin Pack Creator", "Pin Pack Store", "Account Page"]
    
    // TableView method that sets the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in the table is the same as the number of menu options
        return menuOptions.count
    }
    
    // TableView method which defines what to display in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Returns a reusable table-view cell object based on the prototype cell defined in the UI storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: menuOptions[(indexPath as NSIndexPath).row], for: indexPath) as UITableViewCell
        // Sets the cell label as the corresponding menu option
        cell.textLabel?.text = menuOptions[(indexPath as NSIndexPath).row]
        return cell
    }
}
