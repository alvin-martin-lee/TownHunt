//
//  LeaderboardTableViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 07/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class LeaderboardTableViewController: UITableViewController {

    public var selectedPackKey = ""
    public var packCreatorID = ""
    private var packID = ""
    private var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPackID()
        getLeaderboardData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // Retrieves the pack id of the selected pack
    private func getPackID(){
        // Checks that the selectedPackKey and packCreatorID is not empty otherwise an error message is displayed
        if !(self.selectedPackKey.isEmpty || self.packCreatorID.isEmpty){
            let userPackDictName = "UserID-\(packCreatorID)-LocalPacks"
            let defaults = UserDefaults.standard
            if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
                // Opens file and retrieves the pack data and hence the pack id
                let filename = dictOfPacksOnPhone[selectedPackKey] as! String
                let packData = PinPackMapViewController().loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: packCreatorID)
                packID =  packData["PackID"] as! String
            } else{
                displayAlertMessage(alertTitle: "Error", alertMessage: "Data Couldn't be loaded")
            }
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "Selected pack data not passed")
        }
    }
    
    private func getLeaderboardData(){
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    @IBAction func backMenuButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    

}
