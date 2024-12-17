import UIKit

class OrganizerProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var organizerData: [String: Any]?  // Organizer data fetched from Firebase
    var userData: [String: Any]?       // User data fetched from Firebase
    var isUser: Bool = false           // Flag to check if this is a user profile

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the UI based on whether it's a user or an organizer
        setupUI()
        
        // Set up tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        
        // Disable large title for this view controller
        self.navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Dynamically set the name and title based on the data passed
        if let organizer = organizerData {
            nameLabel.text = organizer["name"] as? String
            isUser = false
            self.title = "Organizer Details"
        } else if let user = userData {
            nameLabel.text = user["name"] as? String
            isUser = true
            self.title = "User Details"
        } else {
            nameLabel.text = "No Data Available"
            self.title = "Details"
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If it's a user, we show 2 rows: email and username
        // If it's an organizer, we show 1 row: email
        return isUser ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "organizerprofileTableViewCell", for: indexPath) as! organizerprofileTableViewCell

        if indexPath.row == 0 {
            // Email cell
            cell.configureCell(title: "Email", subtitle: isUser ? userData?["email"] as? String ?? "No email" : organizerData?["email"] as? String ?? "No email")
        } else {
            // Username cell (only for users)
            cell.configureCell(title: "Username", subtitle: isUser ? userData?["username"] as? String ?? "No username available" : "N/A")
        }

        return cell
    }
}
