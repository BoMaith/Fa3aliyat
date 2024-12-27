//
//  HDoneTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-15 on 27/12/2024.
//

import UIKit

class HDoneTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var RateBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!
    
    func setupCell(name: String, date: String) {
        // Set event details
        eventNameLbl.text = name
        eventDateLbl.text = date
    }

    func setRating(isRated: Bool) {
        let starImage = isRated ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        RateBtn.setImage(starImage, for: .normal)
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

