//
//  PaymentTableViewCell.swift
//  Fa3aliyat
//
//  Created by Student on 12/12/2024.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var ImgPayment: UIImageView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblMethod: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(photo : UIImage, type : String) {
        ImgPayment.image = photo
        lblMethod.text = type
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
