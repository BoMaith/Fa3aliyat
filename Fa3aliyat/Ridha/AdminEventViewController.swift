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
    
    // Reviews view outlets
    @IBOutlet weak var reviewsTableView: UITableView!
    
    var participantsList: [Participant] = []  // Array to hold participants data
    var reviewsList: [Review] = []  // Array to hold reviews data

    var eventID: String?  // Assume eventID is provided when selecting an event
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the eventID is set before proceeding
        if eventID == nil {
            print("Event ID is missing.")
            return
        }

        // Initial state: show only the Details view
        detailsView.isHidden = false
        participantsView.isHidden = true
        reviewsView.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Event Details"

        // Setup participants table view
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
        
        // Setup reviews table view
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        
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
            fetchReviews()  // Fetch reviews when "Reviews" is selected
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
            // Check if there are participants
            if let participantsDict = snapshot.value as? [String: Any], !participantsDict.isEmpty {
                // Map the participant data to a Participant model
                self.participantsList = participantsDict.map { (key, value) -> Participant in
                    let participantData = value as? [String: Any] ?? [:]
                    let participant = Participant(
                        id: key,
                        name: participantData["FullName"] as? String ?? "Unknown"
                    )
                    return participant
                }
                
                // Update the participant count in the title
                self.participantsTitle.text = "Participants: \(self.participantsList.count)"
                
                // Reload the participants table view
                self.participantsTableView.reloadData()
            } else {
                // If no participants, display "No participants yet"
                self.participantsTitle.text = "No participants yet"
            }
        }
    }

    // MARK: - Fetch reviews from Firebase
    private func fetchReviews() {
        guard let eventID = eventID else {
            print("Event ID is missing.")
            return
        }
        
        let ref = Database.database().reference()
        
        // Fetch reviews for this event from Firebase
        ref.child("events").child(eventID).child("reviews").observeSingleEvent(of: .value) { snapshot in
            // Check if there are reviews
            if let reviewsDict = snapshot.value as? [String: Any], !reviewsDict.isEmpty {
                // Map the review data to a Review model
                self.reviewsList = reviewsDict.map { (key, value) -> Review in
                    let reviewData = value as? [String: Any] ?? [:]
                    let review = Review(
                        id: key,
                        fullName: reviewData["FullName"] as? String ?? "Unknown",
                        rating: reviewData["rating"] as? Int ?? 0  // Rating as integer
                    )
                    return review
                }
                
                // Reload the reviews table view
                self.reviewsTableView.reloadData()
            } else {
                // If no reviews, reload table view and show empty state
                self.reviewsTableView.reloadData()
            }
        }
    }

    // MARK: - TableView Methods for Participants
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == reviewsTableView {
            return reviewsList.count  // Return the number of reviews
        } else {
            return participantsList.count  // Return the number of participants
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == reviewsTableView {
            let review = reviewsList[indexPath.row]
            
            // Dequeue the cell and cast it to ReviewTableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
            
            // Set up the cell with review's name and rating
            cell.setupCell(fullName: review.fullName, rating: review.rating)
            
            return cell
        } else {
            let participant = participantsList[indexPath.row]
            
            // Dequeue the cell and cast it to ParticipantTableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantTableViewCell
            
            // Set up the cell with participant's name
            cell.setupCell(name: participant.name)
            
            return cell
        }
    }

    // MARK: - Participant Model
    struct Participant {
        var id: String
        var name: String
    }

    // MARK: - Review Model
    struct Review {
        var id: String
        var fullName: String
        var rating: Int  // Rating as an integer
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
