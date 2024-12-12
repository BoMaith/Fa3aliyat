import UIKit

class UsersPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIBarButtonItem!

    struct Organizer {
        var name: String
        var email: String
    }
    
    struct User {
        var name: String
        var email: String
        var username: String
    }

    var organizers: [Organizer] = []
    var users: [User] = [] // Updated to hold User objects

    var isOrganizersSelected: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and dataSource for the tableView
        tableView.delegate = self
        tableView.dataSource = self

        // Sample users
        users = [
            User(name: "John Doe", email: "john@example.com", username: "john_doe_01"),
            User(name: "Jane Smith", email: "jane@example.com", username: "jane_smith_22"),
            User(name: "Chris Johnson", email: "chris@example.com", username: "chris_johnson_33"),
            User(name: "Emily Davis", email: "emily@example.com", username: "emily_davis_44"),
            User(name: "Michael Brown", email: "michael@example.com", username: "michael_brown_55")
        ]

        // Register a custom cell class if using one
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrganizerCellIdentifier")

        updateAddButtonVisibility()

        if #available(iOS 11.0, *) {
            tableView.allowsSelectionDuringEditing = true // Allow selection during swipe actions
        }
    }

    // Update Add Button visibility based on selected segment
    func updateAddButtonVisibility() {
        addButton.isHidden = !isOrganizersSelected
    }

    // Table View Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOrganizersSelected ? organizers.count : users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerCellIdentifier", for: indexPath)

        if isOrganizersSelected {
            let organizer = organizers[indexPath.row]
            cell.textLabel?.text = organizer.name
        } else {
            let user = users[indexPath.row]
            cell.textLabel?.text = user.name // Display the name of the user
        }

        return cell
    }

    // Handle selection of table view rows
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isOrganizersSelected {
            let selectedOrganizer = organizers[indexPath.row]
            
            // Navigate to Organizer Profile screen
            if let storyboard = self.storyboard {
                if let profileVC = storyboard.instantiateViewController(withIdentifier: "OrganizerProfileViewController") as? OrganizerProfileViewController {
                    profileVC.organizer = selectedOrganizer
                    profileVC.isUser = false // Indicate this is an organizer profile
                    navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        } else {
            let selectedUser = users[indexPath.row]
            
            // Navigate to User Profile screen
            if let storyboard = self.storyboard {
                if let profileVC = storyboard.instantiateViewController(withIdentifier: "OrganizerProfileViewController") as? OrganizerProfileViewController {
                    profileVC.user = selectedUser
                    profileVC.isUser = true // Indicate this is a user profile
                    navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Segmented Control Action
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        updateAddButtonVisibility()
    }

    // Navigation to Create Organizer screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createOrganizerVC = segue.destination as? CreateOrganizerViewController {
            createOrganizerVC.delegate = self
        }
    }

    // Swipe-to-delete with confirmation alert
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create the Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            // Show confirmation alert before deletion
            let itemType = self.isOrganizersSelected ? "organizer" : "user"
            
            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this \(itemType)?", preferredStyle: .alert)
            
            // Add Cancel button
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false) // Cancel the deletion
            }))
            
            // Add Delete button
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Proceed with deletion
                if self.isOrganizersSelected {
                    self.organizers.remove(at: indexPath.row)
                } else {
                    self.users.remove(at: indexPath.row)
                }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true) // Confirm the deletion
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.backgroundColor = .red
        
        // Configure the swipe actions
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false // Disable full swipe to delete immediately
        
        return swipeActions
    }
}

// Handle new organizer creation (if applicable)
extension UsersPageViewController: CreateOrganizerDelegate {
    func didCreateOrganizer(_ organizer: Organizer) {
        organizers.append(organizer)
        if isOrganizersSelected {
            tableView.reloadData()
        }
    }
}
