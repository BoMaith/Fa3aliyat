//
//  organizerprofileTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-12 on 17/12/2024.
//

import UIKit

class organizerprofileTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subtitleLabel.textColor = UIColor.lightGray // Set subtitle color to light gray

    }
    func configureCell(title: String, subtitle: String) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
