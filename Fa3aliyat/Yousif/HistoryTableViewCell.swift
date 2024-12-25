//
//  HistoryTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-15 on 24/12/2024.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!
    
    func setupCell(photoName: String, name: String, date: String, isFavorite: Bool) {
        imgEvent.image = UIImage(named: photoName)
        eventNameLbl.text = name
        eventDateLbl.text = date
        
        // Update star button appearance
        starBtn.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
        starBtn.tintColor = isFavorite ? UIColor.systemBlue : UIColor.systemGray
    }
    

    func setupCell2(name: String, date: String, isFavorite: Bool) {
        // Set event details
        eventNameLbl.text = name
        eventDateLbl.text = date
        
        // Set the favorite button's state
        starBtn.isSelected = isFavorite
        
        // Set the image for the button based on the selected state
        if isFavorite {
            starBtn.setImage(UIImage(named: "star_filled"), for: .selected)  // Image for selected state
            starBtn.setImage(UIImage(named: "star_empty"), for: .normal)     // Image for normal state
        } else {
            starBtn.setImage(UIImage(named: "star_empty"), for: .normal)     // Image for normal state
            starBtn.setImage(UIImage(named: "star_filled"), for: .selected)  // Image for selected state
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}