import UIKit
import FirebaseDatabase
import FirebaseAuth

class UsersPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var organizers: [[String: Any]] = [] // Array to store organizer data
    var users: [[String: Any]] = [] // Array to store user data
    
    var isOrganizersSelected: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and dataSource for the tableView
        tableView.delegate = self
        tableView.dataSource = self

        // Register a custom cell class if using one
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrganizerCellIdentifier")

        updateAddButtonVisibility()

        if #available(iOS 11.0, *) {
            tableView.allowsSelectionDuringEditing = true // Allow selection during swipe actions
        }

        // Fetch data based on the initial segment selection
        fetchDataFromFirebase()
    }

    // Fetch organizers or users based on the selected segment
    func fetchDataFromFirebase() {
        let ref = Database.database().reference()
        
        if isOrganizersSelected {
            // Fetch organizers from Firebase Realtime Database
            ref.child("organizers").observe(.value, with: { snapshot in
                var fetchedOrganizers: [[String: Any]] = []
                
                // Loop through the fetched data
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let organizerData = snapshot.value as? [String: Any] {
                        var organizer = organizerData
                        organizer["uid"] = snapshot.key // Add the UID to the dictionary
                        fetchedOrganizers.append(organizer)
                    }
                }
                
                // Update the organizer list and reload the table view
                self.organizers = fetchedOrganizers
                self.tableView.reloadData()
            })
        } else {
            // Fetch users from Firebase Realtime Database
            ref.child("users").observe(.value, with: { snapshot in
                var fetchedUsers: [[String: Any]] = []
                
                // Loop through the fetched data
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let userData = snapshot.value as? [String: Any] {
                        var user = userData
                        user["uid"] = snapshot.key // Add the UID to the dictionary
                        fetchedUsers.append(user)
                    }
                }
                
                // Update the user list and reload the table view
                self.users = fetchedUsers
                self.tableView.reloadData()
            })
        }
    }

    // Update Add Button visibility based on selected segment
    func updateAddButtonVisibility() {
        addButton.isHidden = !isOrganizersSelected
    }

    // Table View Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOrganizersSelected ? organizers.count : users.count // Show organizers or users based on the segment
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerCellIdentifier", for: indexPath)

        if isOrganizersSelected {
            let organizer = organizers[indexPath.row]
            cell.textLabel?.text = organizer["name"] as? String ?? "Unknown"
        } else {
            let user = users[indexPath.row]
            cell.textLabel?.text = user["FullName"] as? String ?? "Unknown"
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
                    profileVC.organizerData = selectedOrganizer
                    navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        } else {
            let selectedUser = users[indexPath.row]
            // Navigate to User Profile screen
            if let storyboard = self.storyboard {
                if let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                    userProfileVC.userData = selectedUser // Pass the user data to the profile view controller
                    navigationController?.pushViewController(userProfileVC, animated: true)
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Segmented Control Action
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        fetchDataFromFirebase() // Fetch the appropriate data based on selected segment
        updateAddButtonVisibility()
    }

    // Swipe-to-delete with confirmation alert
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Check if there is something to delete
                if self.isOrganizersSelected {
                    let organizerToDelete = self.organizers[indexPath.row]
                    if let uid = organizerToDelete["uid"] as? String {
                        self.deleteOrganizerFromFirebase(uid: uid) { success in
                            if success {
                                self.organizers.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                            completionHandler(success)
                        }
                    } else {
                        completionHandler(false) // No valid UID to delete
                    }
                } else {
                    let userToDelete = self.users[indexPath.row]
                    if let uid = userToDelete["uid"] as? String {
                        self.deleteOrganizerFromFirebase(uid: uid) { success in
                            if success {
                                self.users.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                            completionHandler(success)
                        }
                    } else {
                        completionHandler(false) // No valid UID to delete
                    }
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.backgroundColor = .red
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false
        
        return swipeActions
    }

    // Function to delete an organizer from Firebase Realtime Database and Firebase Authentication
    func deleteOrganizerFromFirebase(uid: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference()
        
        // Delete from Firebase Realtime Database
        ref.child("organizers").child(uid).removeValue { error, _ in
            if let error = error {
                print("Error deleting organizer from database: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Delete from Firebase Authentication
            if let currentUser = FirebaseAuth.Auth.auth().currentUser, currentUser.uid == uid {
                currentUser.delete { error in
                    if let error = error {
                        print("Error deleting user from authentication: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("User deleted from authentication successfully.")
                        completion(true)
                    }
                }
            } else {
                // If it's not the current user, just delete from the database
                completion(true)
            }
        }
    }
}
