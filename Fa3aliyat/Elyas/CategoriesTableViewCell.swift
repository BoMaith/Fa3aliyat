//
//  CategoriesTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-10 on 19/12/2024.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCategoryIcon: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(photoName: String, name: String) {
        imgCategoryIcon.image = UIImage(named: photoName)
        lblCategory.text = name
    }

}
