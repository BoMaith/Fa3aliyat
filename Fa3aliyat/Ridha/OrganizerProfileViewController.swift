import UIKit
import FirebaseDatabase

class OrganizerProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var organizerData: [String: Any]?  // Organizer data fetched from Firebase
    var userData: [String: Any]?       // User data fetched from Firebase
    var isUser: Bool = false           // Flag to check if this is a user profile
    var eventsList: [[String: Any]] = [] // Events for the organizer
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var organizerEventsList: UITableView!
    @IBOutlet weak var eventstitle: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the UI based on whether it's a user or an organizer
        setupUI()
        
        // Set up the user detail tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        
        // Set up the organizer events tableView
        organizerEventsList.delegate = self
        organizerEventsList.dataSource = self
        organizerEventsList.rowHeight = UITableView.automaticDimension
        organizerEventsList.estimatedRowHeight = 60.0
        
        // Disable large title for this view controller
        self.navigationItem.largeTitleDisplayMode = .never
        
        // Fetch events if the profile is an organizer
        if !isUser {
            fetchEvents()
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Dynamically set the name, email, and title based on the data passed
        if let organizer = organizerData {
            nameLabel.text = organizer["name"] as? String ?? "Unknown"
            isUser = false
            self.title = "Organizer Details"
            eventstitle.text = "Organizer Events"
        } else if let user = userData {
            let userFullName = user["FullName"] as? String ?? "Unknown"
            let userEmail = user["Email"] as? String ?? "No email"
            let userUsername = user["UserName"] as? String ?? "No username available"
            eventstitle.text = ""
            nameLabel.text = userFullName
            print("User Full Name: \(userFullName)")
            print("User Email: \(userEmail)")
            print("User Username: \(userUsername)")

            isUser = true
            self.title = "User Details"
        } else {
            nameLabel.text = "No Data Available"
            self.title = "Details"
        }
    }

    // MARK: - Fetch Events from Firebase (for Organizer)
    private func fetchEvents() {
        guard let organizerID = organizerData?["uid"] as? String else {
            print("No organizer ID found.")
            return
        }

        let ref = Database.database().reference()
        
        // Access the events node for the specific organizer
        ref.child("organizers").child(organizerID).child("Events").observeSingleEvent(of: .value) { snapshot in
            guard let eventsDict = snapshot.value as? [String: Any] else {
                print("No events found for this organizer.")
                return
            }
            
            // Convert the events dictionary into an array of dictionaries
            self.eventsList = eventsDict.map { (key, value) -> [String: Any] in
                var event = value as? [String: Any] ?? [:]
                event["id"] = key // Adding the event key to the event data
                return event
            }
            
            // Reload the organizer events list table
            self.organizerEventsList.reloadData()
        }
    }

    // MARK: - TableView DataSource for User Details (Main TableView)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            // If it's the main user table, return 2 rows (email and username)
            return isUser ? 2 : 1
        } else {
            // If it's the events table (organizerEventsList), return the number of events
            return eventsList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            // Dequeue the custom cell for user data
            let cell = tableView.dequeueReusableCell(withIdentifier: "organizerprofileTableViewCell", for: indexPath) as! organizerprofileTableViewCell

            if indexPath.row == 0 {
                let email = isUser ? userData?["Email"] as? String ?? "No email" : organizerData?["email"] as? String ?? "No email"
                print("Email: \(email)")  // Debug log to verify the email
                cell.configureCell(title: "Email", subtitle: email)
            } else {
                let username = isUser ? userData?["UserName"] as? String ?? "No username available" : "N/A"
                print("Username: \(username)")  // Debug log to verify the username
                cell.configureCell(title: "Username", subtitle: username)
            }

            return cell
        } else {
            // Dequeue the cell for event details (organizer events list)
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)

            // Get event details for the specific event
            let event = eventsList[indexPath.row]
            let eventName = event["name"] as? String ?? "No event name"

            // Debug: Check if the event name is correct
            print("Event Name: \(eventName)")

            // Set up your cell with event data (only the event name)
            cell.textLabel?.text = eventName

            return cell
        }
    }
}
