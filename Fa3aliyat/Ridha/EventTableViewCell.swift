//
//  EventTableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-12 on 19/12/2024.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    func configureCell(eventName: String, eventDate: String) {
        eventTitleLabel.text = eventName
        eventDateLabel.text = eventDate
    }
}

