//
//  EventTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-12 on 19/12/2024.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var eventImageView: UIImageView!  // This will hold the image for the event

        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            eventImageView.layer.cornerRadius = eventImageView.frame.size.width / 2  // Optional: Make image rounded
            eventImageView.clipsToBounds = true
        }

        // Configure the cell to accept and display an image
        func configureCell(image: UIImage?) {
            eventImageView.image = image  // Set the image for the event
        }
}

