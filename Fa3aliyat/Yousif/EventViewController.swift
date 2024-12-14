	//
//  EventViewController.swift
//  Fa3aliyat
//
//  Created by Student on 12/12/2024.
//

import UIKit

class EventViewController: UIViewController {

    
    @IBOutlet weak var CardBtn: UIButton!
    
    @IBOutlet weak var CashBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initial button states
        CardBtn.isSelected = false
        CashBtn.isSelected = false
                
                // Set default images
        CardBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        CardBtn.setImage(UIImage(systemName: "checkmark.circle.fill"),for: .selected)
                
        CashBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        CashBtn.setImage(UIImage(systemName: "checkmark.circle.fill"),for: .selected)
     
    }
    @IBAction func PaymentTapped(_ sender: UIButton) {
        if sender == CardBtn {
            // Select Card, Deselect Cash
            CardBtn.isSelected = true
            CashBtn.isSelected = false
        } else if sender == CashBtn {
            // Select Cash, Deselect Card
            CardBtn.isSelected = false
            CashBtn.isSelected = true
        }
    }
    
   
    

   
}
