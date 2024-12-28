import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // Creating outlets
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var userRole: String = "users" // Variable to track the user role
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchUserData()
    }
    
    // Function for fetching user data
    func fetchUserData() {
        // Get the current user ID
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        let userID = user.uid
        let userEmail = user.email ?? ""
        print("User ID: \(userID)") // Debugging: Verify user ID
        
        // Determine the user's role based on the email domain
        if userEmail.contains("@fa3aliyat.organizer.bh") {
            userRole = "organizers"
        } else if userEmail.contains("@fa3aliyat.admin.bh") {
            userRole = "admins" // Corrected to match the correct node
        } else {
            userRole = "users"
        }
        
        // Get a reference to the database
        let ref = Database.database().reference()
        
        // Fetch user data from the appropriate node in the database
        ref.child(userRole).child(userID).observeSingleEvent(of: .value, with: { snapshot in
            print("Snapshot: \(snapshot)") // Debugging: Print snapshot data
            
            // Get snapshot of a single event, aka getting a full name and the email
            guard let value = snapshot.value as? [String: Any] else {
                print("No value found in snapshot")
                return
            }
            
            // Update labels with user data using struct
            DispatchQueue.main.async {
                if self.userRole == "organizers" {
                    if let fullName = value["FullName"] as? String,
                       let email = value["Email"] as? String {
                        let organizer = Organizer(fullName: fullName, email: email)
                        print("Full Name: \(organizer.fullName), Email: \(organizer.email)") // Debugging: Verify fetched data
                        
                        // Change the labels to the email and full name
                        self.fullNameLabel.text = organizer.fullName
                        self.emailLabel.text = organizer.email
                    } else {
                        print("FullName or Email not found in snapshot")
                    }
                } else if self.userRole == "admins" {
                    if let fullName = value["FullName"] as? String,
                       let email = value["Email"] as? String {
                        let admin = Admin(fullName: fullName, userEmail: email)
                        print("Full Name: \(admin.fullName), Email: \(admin.userEmail)") // Debugging: Verify fetched data
                        
                        // Change the labels to the email and full name
                        self.fullNameLabel.text = admin.fullName
                        self.emailLabel.text = admin.userEmail
                    } else {
                        print("FullName or Email not found in snapshot")
                    }
                } else {
                    if let fullName = value["FullName"] as? String,
                       let email = value["Email"] as? String {
                        let user = User(fullName: fullName, userEmail: email)
                        print("Full Name: \(user.fullName), Email: \(user.userEmail)") // Debugging: Verify fetched data
                        
                        // Set the labels of the user email and full name
                        self.fullNameLabel.text = user.fullName
                        self.emailLabel.text = user.userEmail
                    } else {
                        print("FullName or Email not found in snapshot")
                    }
                }
                self.tableView.reloadData() // Reload table view to reflect changes
            }
        }) { error in
            print("Error fetching user data: \(error.localizedDescription)") // Debugging: Print any errors
        }
    }
}

// This function is for when the user selects (clicks) a row
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform actions based on the selected row
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "goToDarkMode", sender: self)
        case 1:
            self.performSegue(withIdentifier: "showChangePassword", sender: self)
        case 2:
            if self.userRole == "users" {
                self.performSegue(withIdentifier: "showChangeInterests", sender: self)
            } else {
                showLogoutAlert()
            }
        case 3:
            showLogoutAlert()
        default:
            break
        }
    }
    
    // Function to show logout alert and handle logout
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            do {
                // Logging out the user from the application
                try Auth.auth().signOut()
                if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    self.view.window?.rootViewController = loginViewController
                    self.view.window?.makeKeyAndVisible()
                }
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    // This function returns the amount of sections our table has
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We have one section in our table
    }
    
    // This function returns the number of rows in our table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userRole == "users" ? 4 : 3 // Adjust the number of rows based on the user role
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        // Adding a right arrow in each cell except dark mode cell
        cell.accessoryType = .disclosureIndicator
        
        // Adding custom background to our cell
        cell.backgroundColor = .customBackground
        
        // Show the right text and subtitle for each row
        switch indexPath.row {
        case 0:
            // The dark mode cell does not have a right arrow
            cell.accessoryType = .none
            cell.textLabel?.text = "Dark/Light Mode"
            cell.detailTextLabel?.text = "Enable/Disable dark mode"
        case 1:
            cell.textLabel?.text = "Change Password"
            cell.detailTextLabel?.text = "Update your password"
        case 2:
            if self.userRole == "users" {
                cell.textLabel?.text = "Change Interests"
                cell.detailTextLabel?.text = "Update your interests"
            } else {
                cell.textLabel?.text = "Log Out"
                cell.detailTextLabel?.text = "Log out of your account"
            }
        case 3:
            cell.textLabel?.text = "Log Out"
            cell.detailTextLabel?.text = "Log out of your account"
        default:
            break
        }
        
        return cell
    }
}
