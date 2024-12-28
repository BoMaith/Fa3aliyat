import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class UsersPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var profileImage: UIImageView!
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
                        
                        // Fetch the profile image
                        if let profileImageUrlString = organizer["profileImageUrl"] as? String {
                            let storageRef = Storage.storage().reference(forURL: profileImageUrlString)
                            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("Error fetching profile image: \(error.localizedDescription)")
                                } else if let data = data, let image = UIImage(data: data) {
                                    organizer["profileImage"] = image
                                }
                                // Update the organizer list and reload the table view
                                self.organizers = fetchedOrganizers
                                self.tableView.reloadData()
                            }
                        } else {
                            fetchedOrganizers.append(organizer)
                        }
                    }
                }
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
                        
                        // Fetch the profile image
                        if let profileImageUrlString = user["profileImageUrl"] as? String {
                            let storageRef = Storage.storage().reference(forURL: profileImageUrlString)
                            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("Error fetching profile image: \(error.localizedDescription)")
                                } else if let data = data, let image = UIImage(data: data) {
                                    user["profileImage"] = image
                                }
                                // Update the user list and reload the table view
                                self.users = fetchedUsers
                                self.tableView.reloadData()
                            }
                        } else {
                            fetchedUsers.append(user)
                        }
                    }
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        if isOrganizersSelected {
            let organizer = organizers[indexPath.row]
            let name = organizer["FullName"] as? String ?? "Unknown"
            let image = organizer["profileImage"] as? UIImage
            cell.setupCell(name: name, image: image)
        } else {
            let user = users[indexPath.row]
            let name = user["FullName"] as? String ?? "Unknown"
            let image = user["profileImage"] as? UIImage
            cell.setupCell(name: name, image: image)
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
                if let userProfileVC = storyboard.instantiateViewController(withIdentifier: "OrganizerProfileViewController") as? OrganizerProfileViewController {
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

    // Remove the swipe action methods and any delete logic
}
