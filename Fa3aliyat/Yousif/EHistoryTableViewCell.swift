//
//  HistoryTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-15 on 26/12/2024.
//

import UIKit

class EHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!

    // Setup cell for filtered events (just name and icon)
    func setupCellFilter(photoName: String, name: String) {
        if let image = UIImage(named: photoName) {
            imgEvent.image = image
        } else {
            imgEvent.image = UIImage(named: "default_icon") // Default image
        }
        eventNameLbl.text = name
    }

    // Full setup cell (for both name, date, and favorite status)
    func setupCell(photoName: String, name: String, date: String, isFavorite: Bool) {
        if let image = UIImage(named: photoName) {
            imgEvent.image = image
        } else {
            imgEvent.image = UIImage(named: "default_icon") // Default image
        }
        eventNameLbl.text = name
        eventDateLbl.text = date

        // Update star button appearance based on favorite status
        let starImageName = isFavorite ? "star.fill" : "star"
        starBtn.setImage(UIImage(systemName: starImageName), for: .normal)
        starBtn.tintColor = isFavorite ? UIColor.systemBlue : UIColor.systemGray
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
    