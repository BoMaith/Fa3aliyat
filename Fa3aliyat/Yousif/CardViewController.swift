//
//  CardViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-11 on 17/12/2024.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var CNameF: UITextField!
    @IBOutlet weak var CNumF: UITextField!
    @IBOutlet weak var CDateF: UIDatePicker!
    @IBOutlet weak var CVVF: UITextField!
    @IBOutlet weak var PayBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Card Details"
        // Initially, disable the Pay button
//                PayBtn.isEnabled = false
//                PayBtn.alpha = 0.5
        // Do any additional setup after loading the view.
    }
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        // Validate Card Name
        guard let cardName = CNameF.text, isValidCardName(cardName)     else {
            showAlert(message: "Please enter a valid card name.")
            return
        }

        // Validate Card Number (Visa, MasterCard, etc. - 13 to 19 digits)
        guard let cardNumber = CNumF.text, isValidCardNumber(cardNumber) else {
            showAlert(message: "Please enter a valid card number.")
            return
        }

        // Validate Expiry Date (Must be a future date)
        let currentDate = Date()
        if CDateF.date < currentDate {
            showAlert(message: "Please select a valid expiry date.")
            return
        }

        // Validate CVV (3 digits for most cards)
        guard let cvv = CVVF.text, isValidCVV(cvv) else {
            showAlert(message: "Please enter a valid CVV.")
            return
        }

        // All validations passed, proceed with payment
        proceedWithPayment()
    }

    // Helper Functions
    func isValidCardName(_ name: String) -> Bool {
        let cardNameRegex = "^[A-Za-z ]+$"  // Only letters and spaces
        let predicate = NSPredicate(format: "SELF MATCHES %@", cardNameRegex)
        return predicate.evaluate(with: name)
    }
    
    func isValidCardNumber(_ number: String) -> Bool {
        let cleanedNumber = number.replacingOccurrences(of: " ", with: "")
        let cardNumberRegex = "^[0-9]{13,19}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", cardNumberRegex)
        return predicate.evaluate(with: cleanedNumber)
    }

    func isValidCVV(_ cvv: String) -> Bool {
        let cvvRegex = "^[0-9]{3,4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", cvvRegex)
        return predicate.evaluate(with: cvv)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func proceedWithPayment() {
        // Create a confirmation alert
            let alert = UIAlertController(title: "Confirm Payment",
                                          message: "Are you sure you want to proceed with the payment?",
                                          preferredStyle: .alert)
            
            // Add a "Cancel" action to dismiss the alert without proceeding
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Add a "Proceed" action to confirm the payment
            alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                // Implement payment logic here
                print("Payment successful!")

                // Show success message after payment confirmation
                let successAlert = UIAlertController(title: "Payment Successful",
                                                     message: "Your payment has been processed successfully.",
                                                     preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(successAlert, animated: true, completion: nil)
            }))
            
            // Present the confirmation alert
            present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
