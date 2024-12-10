//
//  HomeTableViewCell.swift
//  Testing
//
//  Created by BP-36-201-17 on 10/12/2024.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!
    
    func setupCell(photoName: String, name: String, date: String) {
        imgEvent.image = UIImage(named: photoName)
        eventNameLbl.text = name
        eventDateLbl.text = date
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
