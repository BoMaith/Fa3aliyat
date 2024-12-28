import UIKit
import FirebaseAuth
import FirebaseDatabase

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
    var pricePerTicket: Double = 2.5
    var eventID: String?
    var eventName: String? // To hold the fetched event name
    var userID: String = ""
    var userName: String = "Anonymous" // Default fallback name

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment"
        
        // Fetch the user ID and name dynamically
        fetchCurrentUserDetails()
        
        if let eventID = eventID {
            print("Received Event ID: \(eventID)")
            fetchEventName(eventID: eventID)
        }

        // Disable ProceedBtn initially
        ProceedBtn.isEnabled = false
        ProceedBtn.alpha = 0.5
        
        // Initial button states
        CardBtn.isSelected = false
        CashBtn.isSelected = false
        
        // Set default images
        CardBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        CardBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        CashBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        CashBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        
        // Initialize price per ticket from PPTLabel
        if let priceText = PPTLabel.text, let price = Double(priceText) {
            pricePerTicket = price
        }
        
        // Set TALabel's text to the initial price per ticket
        TALabel.text = PPTLabel.text
        TTLabel.text = "1"
        updateTotalAmount()
    }

    func updateTotalAmount() {
        let totalAmount = Double(ticketCount) * pricePerTicket
        TALabel.text = "BD " + String(format: "%.1f", totalAmount)
    }

    func fetchEventName(eventID: String) {
        let ref = Database.database().reference().child("events").child(eventID)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let eventData = snapshot.value as? [String: Any],
               let title = eventData["title"] as? String {
                self.eventName = title
                print("Fetched Event Title: \(title)")
            } else {
                print("Error: Unable to fetch event title for ID \(eventID).")
            }
        }
    }

    /// Fetch the current user's ID and name from Firebase Authentication
    func fetchCurrentUserDetails() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No authenticated user found.")
            return
        }
        
        // Set userID and userName
        userID = user.uid
        userName = user.displayName ?? "Anonymous"
        print("Fetched User ID: \(userID), User Name: \(userName)")
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
            checkIfUserIsAlreadyEnrolled { alreadyEnrolled in
                if !alreadyEnrolled {
                    self.performSegue(withIdentifier: "CardPaymentVC", sender: sender)
                } else {
                    // User is already enrolled
                    let alert = UIAlertController(title: "Already Enrolled", message: "You are already enrolled in this event.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if CashBtn.isSelected {
            checkIfUserIsAlreadyEnrolled { alreadyEnrolled in
                if !alreadyEnrolled {
                    self.showApprovalMessage()
                } else {
                    // User is already enrolled
                    let alert = UIAlertController(title: "Already Enrolled", message: "You are already enrolled in this event.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardPaymentVC",
           let destinationVC = segue.destination as? CardViewController {
            destinationVC.eventID = eventID
            destinationVC.eventName = eventName
            destinationVC.userID = userID
            destinationVC.userName = userName
        }
    }

    func checkIfUserIsAlreadyEnrolled(completion: @escaping (Bool) -> Void) {
        guard let eventID = eventID else {
            print("Error: Missing eventID.")
            completion(false)
            return
        }
        
        let eventRef = Database.database().reference().child("events").child(eventID)
        
        eventRef.observeSingleEvent(of: .value) { snapshot in
            if let eventData = snapshot.value as? [String: Any],
               let participants = eventData["participants"] as? [String: Any],
               participants[self.userID] != nil {
                // User is already enrolled
                completion(true)
            } else {
                // User is not enrolled
                completion(false)
            }
        }
    }

    func showApprovalMessage() {
        let alert = UIAlertController(title: "Registration Approval",
                                      message: "Your registration has been approved!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.updateUserEventInFirebase()
            self.ProceedBtn.isEnabled = false
            self.ProceedBtn.alpha = 0.5

            // Navigate back to the HomeViewController
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }


    func updateUserEventInFirebase() {
        guard let eventID = eventID, let eventName = eventName else {
            print("Error: Missing eventID or eventName.")
            return
        }
        
        let ref = Database.database().reference()
        let timestamp = Date().timeIntervalSince1970
        let userEventsRef = ref.child("users").child(userID).child("JoinedEvents")
        let newEvent = ["id": eventID, "name": eventName, "timestamp": timestamp] as [String : Any]
        
        userEventsRef.observeSingleEvent(of: .value) { snapshot in
            var eventsList = snapshot.value as? [[String: Any]] ?? []
            
            if !eventsList.contains(where: { $0["id"] as? String == eventID }) {
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
                participants[self.userID] = ["FullName": self.userName]
                eventData["participants"] = participants
                
                eventRef.setValue(eventData) { error, _ in
                    if let error = error {
                        print("Error updating event participants: \(error.localizedDescription)")
                    } else {
                        print("Event participants updated successfully!")
                    }
                }
            }
        }
    }
}
