//
//  SearchTableViewCell.swift
//  Testing
//
//  Created by BP-36-201-19 on 14/12/2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!
    
    
    func setupCellFilter(photoName: String, name: String) {
           imgEvent.image = UIImage(named: photoName)
           eventNameLbl.text = name
       }
    
    
    func setupCell(photoName: String, name: String, date: String, isFavorite: Bool) {
            imgEvent.image = UIImage(named: photoName)
            eventNameLbl.text = name
            eventDateLbl.text = date
           
           // Update star button appearance
           starBtn.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
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
