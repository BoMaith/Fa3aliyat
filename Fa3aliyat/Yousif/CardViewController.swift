import UIKit
import FirebaseDatabase

class CardViewController: UIViewController {

    @IBOutlet weak var CNameF: UITextField!
    @IBOutlet weak var CNumF: UITextField!
    @IBOutlet weak var CDateF: UIDatePicker!
    @IBOutlet weak var CVVF: UITextField!
    @IBOutlet weak var PayBtn: UIButton!
    
    var eventID: String?
    var eventName: String?
    var userID: String? // Updated to `var`
    var userName: String? // Updated to `var`

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Card Details"
        // Check if the user is already enrolled when the view loads
        checkIfUserIsAlreadyEnrolled()
    }

    @IBAction func payButtonTapped(_ sender: UIButton) {
        // Validate Card Name
        guard let cardName = CNameF.text, isValidCardName(cardName) else {
            showAlert(message: "Please enter a valid card name.")
            return
        }

        // Validate Card Number
        guard let cardNumber = CNumF.text, isValidCardNumber(cardNumber) else {
            showAlert(message: "Please enter a valid card number.")
            return
        }

        // Validate Expiry Date
        let currentDate = Date()
        if CDateF.date < currentDate {
            showAlert(message: "Please select a valid expiry date.")
            return
        }

        // Validate CVV
        guard let cvv = CVVF.text, isValidCVV(cvv) else {
            showAlert(message: "Please enter a valid CVV.")
            return
        }

        // Proceed with payment if all validations pass
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
        let proceedAction = UIAlertAction(title: "Proceed", style: .default) { _ in
            // Implement payment logic here (e.g., process payment using a payment gateway)
            print("Payment successful!")
            
            // Store the timestamp for the last payment
            self.storePaymentTimestamp()
            
            // Update Firebase data
            self.updateUserEventInFirebase()

            // Navigate back to the HomeViewController
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        // Add the "Proceed" action to the alert
        alert.addAction(proceedAction)
        
        // Present the confirmation alert
        present(alert, animated: true, completion: nil)
    }



    func updateUserEventInFirebase() {
        guard let eventID = eventID, let eventName = eventName else {
            print("Error: Missing eventID or eventName.")
            return
        }

        let ref = Database.database().reference()
        let userEventsRef = ref.child("users").child(userID!).child("JoinedEvents")
        let newEvent = ["id": eventID, "name": eventName, "timestamp": Date().timeIntervalSince1970] as [String: Any]

        userEventsRef.observeSingleEvent(of: .value) { snapshot in
            var eventsList = snapshot.value as? [[String: Any]] ?? []
            eventsList.append(newEvent)
            userEventsRef.setValue(eventsList) { error, _ in
                if let error = error {
                    print("Error updating user events: \(error.localizedDescription)")
                } else {
                    print("User events updated successfully!")
                    self.updateEventParticipantsInFirebase()
                }
            }
        }
    }

    func updateEventParticipantsInFirebase() {
        guard let eventID = eventID else {
            print("Error: Missing eventID.")
            return
        }

        let eventRef = Database.database().reference().child("events").child(eventID)
        eventRef.observeSingleEvent(of: .value) { snapshot in
            if var eventData = snapshot.value as? [String: Any] {
                var participants = eventData["participants"] as? [String: Any] ?? [:]
                participants[self.userID!] = ["FullName": self.userName!]
                eventData["participants"] = participants
                eventRef.setValue(eventData) { error, _ in
                    if let error = error {
                        print("Error updating event participants: \(error.localizedDescription)")
                    } else {
                        print("Event participants updated successfully!")
                    }
                }
            } else {
                print("Error: Event data not found.")
            }
        }
    }

    func checkIfUserIsAlreadyEnrolled() {
        guard let eventID = eventID else {
            print("Error: Missing eventID.")
            return
        }
        
        let eventRef = Database.database().reference().child("events").child(eventID)
        
        eventRef.observeSingleEvent(of: .value) { snapshot in
            if let eventData = snapshot.value as? [String: Any],
               let participants = eventData["participants"] as? [String: Any],
               participants[self.userID!] != nil {
                // User is already enrolled
                let alert = UIAlertController(title: "Already Enrolled", message: "You are already enrolled in this event.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // Disable Proceed button
                self.PayBtn.isEnabled = false
                self.PayBtn.alpha = 0.5
            } else {
                // Enable Proceed button
                self.PayBtn.isEnabled = true
                self.PayBtn.alpha = 1.0
            }
        }
    }

    func storePaymentTimestamp() {
        let currentTimestamp = Date().timeIntervalSince1970
        UserDefaults.standard.set(currentTimestamp, forKey: "lastPaymentTimestamp")
    }
}
