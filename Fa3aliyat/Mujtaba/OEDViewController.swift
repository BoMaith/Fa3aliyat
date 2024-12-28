import UIKit
import FirebaseDatabase

class OEDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var participantsView: UIView!
    @IBOutlet weak var reviewsView: UIView!
    
    @IBOutlet weak var orgImage: UIImageView!
    @IBOutlet weak var orgName: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Etitle: UILabel!
    @IBOutlet weak var Edescription: UILabel!
    @IBOutlet weak var Eprice: UILabel!
    @IBOutlet weak var Elocation: UILabel!
    @IBOutlet weak var AvgRate: UILabel!
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
        
        fetchEventDetails()

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

    




   
   /* private func showDeleteConfirmation(for object: Any, isReview: Bool) {
        let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this \(isReview ? "review" : "participant")?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            if isReview {
                if let review = object as? Review {
                    self.deleteReview(review)  // Proceed to delete review
                }
            } else {
                if let participant = object as? Participant {
                    self.deleteParticipant(participant)  // Proceed to delete participant
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }*/



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

    /// Fetches event details from Firebase for a given event ID
private func fetchEventDetails() {
    guard let eventID = eventID else {
        print("Event ID is missing.")
        return
    }
    
    let ref = Database.database().reference()
    
    // Fetch event details for this event from Firebase
    ref.child("events").child(eventID).observeSingleEvent(of: .value) { snapshot in
        print("Received snapshot: \(snapshot)") // Debugging output

        guard let eventData = snapshot.value as? [String: Any] else {
            print("Error: Unable to parse event data.")
            return
        }

        print("Event data: \(eventData)") // Debugging output

        // Extract event data and provide default values if any field is missing
        let date = eventData["date"] as? String ?? "N/A"
        let description = eventData["description"] as? String ?? "N/A"
        let title = eventData["title"] as? String ?? "N/A"
        let price = eventData["price"] as? Double ?? 0.0
        let orgImageURL = eventData["org-image"] as? String ?? ""
        let location = eventData["location"] as? String ?? "N/A"

        // Update the UI on the main thread
        DispatchQueue.main.async {
            self.Date.text = date
            self.Etitle.text = title
            self.Edescription.text = description
            self.Eprice.text = "Price: \(price)BD" // Format the price
            self.orgName.text = title
            self.Elocation.text = "Location: \(location)"

            // Load organizer image (if any)
            if let url = URL(string: orgImageURL) {
                self.loadImage(from: url)
            }
        }
    }
}


    /// Fetches the average rating for a given event ID from Firebase
    private func fetchAverageRating() {
        guard let eventID = eventID else {
            print("Event ID is missing.")
            return
        }
        
        let ref = Database.database().reference()
        
        // Fetch reviews for this event from Firebase
        ref.child("events").child(eventID).child("reviews").observeSingleEvent(of: .value) { snapshot in
            var totalRating = 0
            var ratingCount = 0

            // Iterate over the reviews to sum up the ratings
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let reviewData = childSnapshot.value as? [String: Any],
                   let rating = reviewData["rating"] as? Int {
                    totalRating += rating
                    ratingCount += 1
                }
            }

            // Calculate the average rating, default to 0.0 if no ratings exist
            let averageRating = ratingCount == 0 ? 0.0 : Double(totalRating) / Double(ratingCount)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.AvgRate.text = String(format: "%.1f", averageRating)  // Display average rating rounded to 1 decimal place
            }
        }
    }


    /// Loads an image from a URL and sets it to the UIImageView
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Error: Unable to load image data.")
                return
            }
            DispatchQueue.main.async {
                self.orgImage.image = image
            }
        }.resume()
    }
        }
