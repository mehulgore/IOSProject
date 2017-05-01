//
//  SchedTableViewCell.swift
//  IOSProject
//
//  Created by Mehul Gore on 4/30/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit

class SchedTableViewCell: UITableViewCell {
    
    var count = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func toggleCell () {
        self.count += 1
        if (count == Main.numOptions) {
            count = 0
        }
    }
    
}
