//
//  PTVCTableViewCell.swift
//  Fa3aliyat
//
//  Created by MacBook on 01/01/2025.
//

import UIKit

class PTVCTableViewCell: UITableViewCell {


    // Outlets for name label and profile image
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // This method sets up the cell with the participant's name and image
    func setupCell(name: String) {
        nameLabel.text = name  // Set the name label to the participant's name
      
    }
}
