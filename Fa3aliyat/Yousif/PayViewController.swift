//
//  PayViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-15 on 19/12/2024.
//

import UIKit

class PayViewController: UIViewController {

    
    @IBOutlet weak var CardBtn: UIButton!
    
    @IBOutlet weak var CashBtn: UIButton!
    
    
    @IBOutlet weak var ProceedBtn: UIButton!
    
    
    @IBOutlet weak var TTLabel: UILabel!
    
    @IBOutlet weak var PPTLabel: UILabel!
    
    @IBOutlet weak var TALabel: UILabel!
    
    @IBOutlet weak var TAddBtn: UIButton!
    
    @IBOutlet weak var TDBtn: UIButton!
    
    var ticketCount = 1
    var pricePerTicket: Double = 2.50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment"
        // Disable ProceedBtn initially
               ProceedBtn.isEnabled = false
               ProceedBtn.alpha = 0.5
               
        // Initial button states
                CardBtn.isSelected = false
                CashBtn.isSelected = false
                
                // Set default images
                CardBtn.setImage(UIImage(systemName: "circle"), for: .normal)
                CardBtn.setImage(UIImage(systemName: "checkmark.circle.fill"),for: .selected)
                
                CashBtn.setImage(UIImage(systemName: "circle"), for: .normal)
                CashBtn.setImage(UIImage(systemName: "checkmark.circle.fill"),for: .selected)
        
        
        // Initialize price per ticket from PPTLabel
              if let priceText = PPTLabel.text, let price = Double(priceText) {
                  pricePerTicket = price
              }
              
              // Set TALabel's text to the initial price per ticket
              TALabel.text = PPTLabel.text
              
              // Initialize TTLabel to show 0 tickets
              TTLabel.text = "1"
              
              // Update total amount to reflect the initial state
              updateTotalAmount()
        
     
    }
    
    @IBAction func increaseTicketCount(_ sender: UIButton) {
        ticketCount += 1
        TTLabel.text = "\(ticketCount)"
        updateTotalAmount()
    }
    
    @IBAction func decreaseTicketCount(_ sender: UIButton) {
        if ticketCount > 1 {
                   ticketCount -= 1
                   TTLabel.text = "\(ticketCount)"
                   updateTotalAmount()
               }
    }
    
    func updateTotalAmount() {
        let totalAmount = Double(ticketCount) * pricePerTicket
        TALabel.text = "BD "+String(format: "%.2f", totalAmount)
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
        
        // Enable ProceedBtn after selection
                ProceedBtn.isEnabled = true
                ProceedBtn.alpha = 1.0
    }
    
   
    @IBAction func proceedButtonTapped(_ sender: Any) {
        if CardBtn.isSelected {
               // Navigate to Card Payment Page
//               let cardVC = storyboard?.instantiateViewController(withIdentifier: "CardPaymentVC") as! CardViewController
//               self.navigationController?.pushViewController(cardVC, animated: true)
            self.performSegue(withIdentifier: "CardPaymentVC", sender: sender)
           } else if CashBtn.isSelected {
               // Create the alert
               let alert = UIAlertController(title: "Registration Approval",
                                             message: "Your registration has been approved!",
                                             preferredStyle: .alert)
               
               // Add OK button to dismiss the popup
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               
               // Present the alert
               self.present(alert, animated: true, completion: nil)
               
               //code to navigate to use home page
               
               
           }
       }
}
