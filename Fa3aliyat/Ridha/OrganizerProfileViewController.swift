import UIKit

class OrganizerProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    var organizer: UsersPageViewController.Organizer? // Organizer data to display
    var user: UsersPageViewController.User?           // User data to display
    var isUser: Bool = false                           // Flag to check if this is a user profile

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the UI based on whether it's a user or an organizer
        setupUI()

        // Set up the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Dynamically set the name and title
        if let organizer = organizer {
            nameLabel.text = organizer.name
            isUser = false
            self.title = "Organizer Details"
        } else if let user = user {
            nameLabel.text = user.name
            isUser = true
            self.title = "User Details"
        } else {
            nameLabel.text = "No Data Available"
            self.title = "Details"
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUser ? 2 : 1 // If user, show 2 rows (email and username); if organizer, show 1 row (email)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Email cell
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "InfoCell")
            cell.textLabel?.text = "Email"
            if isUser {
                cell.detailTextLabel?.text = user?.email
            } else {
                cell.detailTextLabel?.text = organizer?.email
            }
            cell.selectionStyle = .none
            return cell
        } else {
            // Username cell (only for users)
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UsernameCell")
            cell.textLabel?.text = "Username"
            if isUser {
                cell.detailTextLabel?.text = user?.username ?? "No username available"
            } else {
                cell.detailTextLabel?.text = "N/A"
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
