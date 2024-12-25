import UIKit
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
    var userID: String = "ivb3nvgo3jYi3WJdA83KKjmWeJf2" // Replace with the actual user's ID
    var userName: String = "John Doe" // Replace with the actual user's name

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment"
        
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
        // Reference to Firebase
        let ref = Database.database().reference().child("events").child(eventID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let eventData = snapshot.value as? [String: Any],
               let name = eventData["name"] as? String {
                self.eventName = name
                print("Fetched Event Name: \(name)")
            } else {
                print("Error: Unable to fetch event name for ID \(eventID).")
            }
        }
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
            self.performSegue(withIdentifier: "CardPaymentVC", sender: sender)
        } else if CashBtn.isSelected {
            // Check if the user can join the event based on the last joined timestamp
            checkIfUserCanJoinEvent()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardPaymentVC",
           let destinationVC = segue.destination as? CardViewController {
            destinationVC.eventID = eventID
            destinationVC.eventName = eventName
            destinationVC.userID = userID // Ensure `userID` is `var` in `CardViewController`
            destinationVC.userName = userName // Ensure `userName` is `var` in `CardViewController`
        }
    }

    func checkIfUserCanJoinEvent() {
        guard let eventID = eventID else {
            print("Error: Missing eventID.")
            return
        }
        
        // Reference to Firebase for user's events
        let userEventsRef = Database.database().reference().child("users").child(userID).child("JoinedEvents")
        
        userEventsRef.observeSingleEvent(of: .value) { snapshot in
            if let events = snapshot.value as? [[String: Any]] {
                for event in events {
                    if let joinedEventID = event["id"] as? String, joinedEventID == eventID,
                       let timestamp = event["timestamp"] as? Double {
                        // Check if 24 hours have passed since the last join
                        let currentTimestamp = Date().timeIntervalSince1970
                        let timeDifference = currentTimestamp - timestamp
                        
                        if timeDifference < 24 * 60 * 60 { // Less than 24 hours
                            // User joined the event within the last 24 hours
                            let alert = UIAlertController(title: "Error", message: "You can only join this event once every 24 hours.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    }
                }
            }
            
            // If no event or more than 24 hours have passed, show the approval message
            self.showApprovalMessage()
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
                var participants = eventData["participants"] as? [[String: Any]] ?? []
                let user = ["id": self.userID, "name": self.userName]
                participants.append(user)
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
