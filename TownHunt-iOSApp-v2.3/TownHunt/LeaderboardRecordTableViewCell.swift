//
//  LeaderboardRecordTableViewCell.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  File defines the prototype leaderboard record cell

import UIKit // UIKit constructs and manages the app's UI

// Class defines the prototype cell that each leaderboard record cell is based upon
class LeaderboardRecordTableViewCell: UITableViewCell {

    // Outlets connect UI elements to the code, thus making UI elements accessible programmatically
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var pointsScoreLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
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
