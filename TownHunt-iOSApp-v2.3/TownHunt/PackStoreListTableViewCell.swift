//
//  PackListTableViewCell.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  File defines the prototype pack detail cell

import UIKit // UIKit constructs and manages the app's UI

// Class defines the prototype cell that each pack detail cell is based upon
class PackStoreListTableViewCell: UITableViewCell {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var packNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! 
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    // Called when the cell is loaded into the table
    override func awakeFromNib() {
        // Sets up the functionality of the cell
        super.awakeFromNib()
    }
    
    // Called when the cell is selected in the table
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Changes the colour of the cell
        super.setSelected(selected, animated: animated)
    }
}
