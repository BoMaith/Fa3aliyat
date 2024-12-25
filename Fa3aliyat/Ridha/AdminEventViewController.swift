import UIKit
import FirebaseDatabase

class AdminEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var participantsView: UIView!
    @IBOutlet weak var reviewsView: UIView!
    
    // Participants view outlets
    @IBOutlet weak var participantsTitle: UILabel!
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var participantsTabelCell: UITableViewCell!  // Keeps the outlet intact
    
    // Reviews view outlet
    @IBOutlet weak var reviewsTableView: UITableView!
    
    var participantsList: [Participant] = []  // Array to hold participants data
    var eventID: String?  // Assume eventID is provided when selecting an event
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the eventID is set before proceeding
        
        
        // Initial state: show only the Details view
        detailsView.isHidden = false
        participantsView.isHidden = true
        reviewsView.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Event Details"

        // Setup participants table view
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
        
        // Fetch participants for the event once the view loads
        fetchParticipants()
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        // Hide all views first
        detailsView.isHidden = true
        participantsView.isHidden = true
        reviewsView.isHidden = true

        // Show the selected view
        switch sender.selectedSegmentIndex {
        case 0:
            self.title = "Event Details"
            detailsView.isHidden = false
        case 1:
            self.title = "Participants"
            participantsView.isHidden = false
            participantsTitle.text = "Loading participants..."
            fetchParticipants()  // Fetch participants when "Participants" is selected
        case 2:
            self.title = "Reviews"
            reviewsView.isHidden = false
        default:
            break
        }
    }

    // MARK: - Fetch participants from Firebase
    private func fetchParticipants() {
        guard let eventID = eventID else {
            print("Event ID is missing.")
            return
        }
        
        let ref = Database.database().reference()
        
        // Fetch participants for this event from Firebase
        ref.child("events").child(eventID).child("participants").observeSingleEvent(of: .value) { snapshot in
            guard let participantsDict = snapshot.value as? [String: Any] else {
                print("No participants found for this event.")
                return
            }
            
            // Map the participant data to a Participant model
            self.participantsList = participantsDict.map { (key, value) -> Participant in
                let participantData = value as? [String: Any] ?? [:]
                let participant = Participant(
                    id: key,
                    name: participantData["name"] as? String ?? "Unknown",
                    email: participantData["email"] as? String ?? "No email",
                    price: participantData["price"] as? Double ?? 0.0
                )
                return participant
            }
            
            // Update the participant count in the title
            self.participantsTitle.text = "Participants: \(self.participantsList.count)"
            
            // Reload the participants table view
            self.participantsTableView.reloadData()
        }
    }

    // MARK: - TableView Methods for Participants
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsList.count  // Return the number of participants
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participant = participantsList[indexPath.row]
        
        // Dequeue the cell and cast it to ParticipantTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantTableViewCell
        
        // Set up the cell with participant's name
        cell.setupCell(name: participant.name)
        
        return cell
    }

    // MARK: - Participant Model
    struct Participant {
        var id: String
        var name: String
        var email: String
        var price: Double
    }

    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdminEventViewController" {
            // Pass the selected eventID to the destination view controller
            if let adminEventVC = segue.destination as? AdminEventViewController {
                adminEventVC.eventID = self.eventID  // Set eventID
            }
        }
    }
}
