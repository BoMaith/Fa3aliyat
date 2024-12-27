//
//  ChangeInterestsTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP on 27/12/2024.
//

import UIKit

class ChangeInterestsTableViewCell: UITableViewCell {
    @IBOutlet weak var switchInterest: UISwitch!
    @IBOutlet weak var imgInterestIcon: UIImageView!
    @IBOutlet weak var lblInterest: UILabel!
    
    func setupCell(photoName: String, name: String) {
        imgInterestIcon.image = UIImage(named: photoName)
        lblInterest.text = name
    }
    
}
