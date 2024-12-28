//
//  EventCollectionViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-11 on 28/12/2024.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var EventImages: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EventImages.contentMode = .scaleAspectFill
        EventImages.clipsToBounds = true
    }
}
