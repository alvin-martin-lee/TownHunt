//
//  PinCell.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  File defines the prototype pin detail cell

import UIKit  // UIKit constructs and manages the app's UI

// Class defines the prototype cell that each pin detail cell is based upon
class PinCell: UITableViewCell {
    
    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var codewordLabel: UILabel!
    @IBOutlet weak var pointValLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

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
