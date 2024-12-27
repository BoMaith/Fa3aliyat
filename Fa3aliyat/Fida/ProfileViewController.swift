//import UIKit
//import FirebaseDatabase
//import FirebaseAuth
//
//class ProfileViewController: UIViewController {
//
//    // Creating outlets
//    @IBOutlet weak var fullNameLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet var tableview: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableview.delegate = self
//        tableview.dataSource = self
//        fetchUserData()
//    }
//
//    func fetchUserData() {
//        // Get the current user ID
//        guard let user = Auth.auth().currentUser else {
//            print("No user is logged in")
//            return
//        }
//        let userID = user.uid
//        let userEmail = user.email ?? ""
//        print("User ID: \(userID)") // Debugging: Verify user ID
//
//        // Determine the user's role based on the email domain
//        let userRole: String
//        if userEmail.contains("@fa3aliyat.organizer.bh") {
//            userRole = "organizers"
//        } else {
//            userRole = "users"
//        }
//
//        // Get a reference to the database
//        let ref = Database.database().reference()
//
//        // Fetch user data from the appropriate node in the database
//        ref.child(userRole).child(userID).observeSingleEvent(of: .value, with: { snapshot in
//            print("Snapshot: \(snapshot)") // Debugging: Print snapshot data
//
//            guard let value = snapshot.value as? [String: Any] else {
//                print("No value found in snapshot")
//                return
//            }
//
//            // Update labels with user data using struct
//            if userRole == "organizers" {
//                if let name = value["FullName"] as? String,
//                   let email = value["email"] as? String {
//                    let user = User(fullName: name, userEmail: email)
//                    print("Full Name: \(user.fullName), Email: \(user.userEmail)") // Debugging: Verify fetched data
//
//                    DispatchQueue.main.async {
//                        self.fullNameLabel.text = user.fullName
//                        self.emailLabel.text = user.userEmail
//                    }
//                } else {
//                    print("Name or Email not found in snapshot")
//                }
//            } else {
//                if let fullName = value["FullName"] as? String,
//                   let email = value["Email"] as? String {
//                    let user = User(fullName: fullName, userEmail: email)
//                    print("Full Name: \(user.fullName), Email: \(user.userEmail)") // Debugging: Verify fetched data
//
//                    DispatchQueue.main.async {
//                        self.fullNameLabel.text = user.fullName
//                        self.emailLabel.text = user.userEmail
//                    }
//                } else {
//                    print("FullName or Email not found in snapshot")
//                }
//            }
//        }) { error in
//            print("Error fetching user data: \(error.localizedDescription)") // Debugging: Print any errors
//        }
//    }
//}
//
//
//// This function is for when the user selects (clicks) a row
//extension ProfileViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // A switch statement to handle navigation
//        switch indexPath.row {
//        case 0:
//            performSegue(withIdentifier: "darkMode", sender: self)
//        case 1:
//            performSegue(withIdentifier: "showChangeEmail", sender: self)
//        case 2:
//            performSegue(withIdentifier: "showChangePassword", sender: self)
//        case 3:
//            performSegue(withIdentifier: "showChangeInterests", sender: self)
//        case 4:
//            performSegue(withIdentifier: "showTickets", sender: self)
//        case 5:
//            do {
//                // Sign out the users from the application
//                let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
//                    do {
//                        // Sign out the user from the application
//                        try Auth.auth().signOut()
//                        // Redirect to login screen after sign out
//                        if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
//                            self.view.window?.rootViewController = loginViewController
//                            self.view.window?.makeKeyAndVisible()
//                        }
//                    }
//                    catch {
//                        print("Error signing out: \(error.localizedDescription)")
//                    }
//                }))
//                self.present(alert, animated: true, completion: nil)
//                break
//            }
//        default:
//            break
//        }
//    }
//}
//
//extension ProfileViewController: UITableViewDataSource {
//
//    // This function returns the amount of sections our table has
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1 // We have one section in our table
//    }
//
//    // This function returns the number of rows in our table view
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 6 // We have six rows
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//
//        // Adding a right arrow in each cell except dark mode cell
//        cell.accessoryType = .disclosureIndicator
//
//        // Adding custom background to our cell
//        cell.backgroundColor = .customBackground
//
//        // Show the right text and subtitle for each row
//        switch indexPath.row {
//        case 0:
//            // The dark mode cell does not have a right arrow
//            cell.accessoryType = .none
//            cell.textLabel?.text = "Dark/Light Mode"
//            cell.detailTextLabel?.text = "Enable/Disable dark mode"
//        case 1:
//            cell.textLabel?.text = "Change Email"
//            cell.detailTextLabel?.text = "Update your email address"
//        case 2:
//            cell.textLabel?.text = "Change Password"
//            cell.detailTextLabel?.text = "Update your password"
//        case 3:
//            cell.textLabel?.text = "Change Interests"
//            cell.detailTextLabel?.text = "Update your interests"
//        case 4:
//            cell.textLabel?.text = "Tickets"
//            cell.detailTextLabel?.text = "View your tickets"
//        case 5:
//            cell.textLabel?.text = "Log Out"
//            cell.detailTextLabel?.text = "Log out of your account"
//        default:
//            break
//        }
//
//        return cell
//    }
//}

//******************************************************CO PILOT TEST****************************************************************************
import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // Creating outlets
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet var tableview: UITableView!
    
    var isOrganizer = false // Variable to track if the user is an organizer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        fetchUserData()
    }
    
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
        let userRole: String
        if userEmail.contains("@fa3aliyat.organizer.bh") {
            userRole = "organizers"
            isOrganizer = true // Mark the user as an organizer
        } else {
            userRole = "users"
            isOrganizer = false // Mark the user as a regular user
        }
        
        // Get a reference to the database
        let ref = Database.database().reference()
        
        // Fetch user data from the appropriate node in the database
        ref.child(userRole).child(userID).observeSingleEvent(of: .value, with: { snapshot in
            print("Snapshot: \(snapshot)") // Debugging: Print snapshot data
            
            guard let value = snapshot.value as? [String: Any] else {
                print("No value found in snapshot")
                return
            }
            
            // Update labels with user data using struct
            if userRole == "organizers" {
                if let name = value["FullName"] as? String,
                   let email = value["email"] as? String {
                    let organizer = Organizer(fullName: name, email: email)
                    print("Full Name: \(organizer.fullName), Email: \(organizer.email)") // Debugging: Verify fetched data
                    
                    DispatchQueue.main.async {
                        self.fullNameLabel.text = organizer.fullName
                        self.emailLabel.text = organizer.email
                    }
                } else {
                    print("Name or Email not found in snapshot")
                }
            } else {
                if let fullName = value["FullName"] as? String,
                   let email = value["Email"] as? String {
                    let user = User(fullName: fullName, userEmail: email)
                    print("Full Name: \(user.fullName), Email: \(user.userEmail)") // Debugging: Verify fetched data
                    
                    DispatchQueue.main.async {
                        self.fullNameLabel.text = user.fullName
                        self.emailLabel.text = user.userEmail
                    }
                } else {
                    print("FullName or Email not found in snapshot")
                }
            }
        }) { error in
            print("Error fetching user data: \(error.localizedDescription)") // Debugging: Print any errors
        }
    }
}

// This function is for when the user selects (clicks) a row
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // A switch statement to handle navigation
        let effectiveIndex = isOrganizer ? indexPath.row : indexPath.row - 2
        switch effectiveIndex {
        case 0:
            performSegue(withIdentifier: "darkMode", sender: self)
        case 1:
            performSegue(withIdentifier: "showChangeEmail", sender: self)
        case 2:
            performSegue(withIdentifier: "showChangePassword", sender: self)
        case 3:
            performSegue(withIdentifier: "showChangeInterests", sender: self)
        case 4:
            performSegue(withIdentifier: "showTickets", sender: self)
        case 5:
            do {
                // Sign out the users from the application
                let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                    do {
                        // Sign out the user from the application
                        try Auth.auth().signOut()
                        // Redirect to login screen after sign out
                        if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                            self.view.window?.rootViewController = loginViewController
                            self.view.window?.makeKeyAndVisible()
                        }
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                break
            }
        default:
            break
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    // This function returns the amount of sections our table has
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We have one section in our table
    }
    
    // This function returns the number of rows in our table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOrganizer ? 4 : 6 // Adjust the number of rows based on the user role
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        // Adding a right arrow in each cell except dark mode cell
        cell.accessoryType = .disclosureIndicator
        
        // Adding custom background to our cell
        cell.backgroundColor = .customBackground
        
        // Show the right text and subtitle for each row
        if isOrganizer {
            switch indexPath.row {
            case 0:
                // The dark mode cell does not have a right arrow
                cell.accessoryType = .none
                cell.textLabel?.text = "Dark/Light Mode"
                cell.detailTextLabel?.text = "Enable/Disable dark mode"
            case 1:
                cell.textLabel?.text = "Change Email"
                cell.detailTextLabel?.text = "Update your email address"
            case 2:
                cell.textLabel?.text = "Change Password"
                cell.detailTextLabel?.text = "Update your password"
            case 3:
                cell.textLabel?.text = "Log Out"
                cell.detailTextLabel?.text = "Log out of your account"
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                // The dark mode cell does not have a right arrow
                cell.accessoryType = .none
                cell.textLabel?.text = "Dark/Light Mode"
                cell.detailTextLabel?.text = "Enable/Disable dark mode"
            case 1:
                cell.textLabel?.text = "Change Email"
                cell.detailTextLabel?.text = "Update your email address"
            case 2:
                cell.textLabel?.text = "Change Password"
                cell.detailTextLabel?.text = "Update your password"
            case 3:
                cell.textLabel?.text = "Change Interests"
                cell.detailTextLabel?.text = "Update your interests"
            case 4:
                cell.textLabel?.text = "Tickets"
                cell.detailTextLabel?.text = "View your tickets"
            case 5:
                cell.textLabel?.text = "Log Out"
                cell.detailTextLabel?.text = "Log out of your account"
            default:
                break
            } // Show the right text and subtitle for each row
            if isOrganizer {
                switch indexPath.row {
                case 0:
                    // The dark mode cell does not have a right arrow
                    cell.accessoryType = .none
                    cell.textLabel?.text = "Dark/Light Mode"
                    cell.detailTextLabel?.text = "Enable/Disable dark mode"
                case 1:
                    cell.textLabel?.text = "Change Email"
                    cell.detailTextLabel?.text = "Update your email address"
                case 2:
                    cell.textLabel?.text = "Change Password"
                    cell.detailTextLabel?.text = "Update your password"
                case 3:
                    cell.textLabel?.text = "Log Out"
                    cell.detailTextLabel?.text = "Log out of your account"
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    // The dark mode cell does not have a right arrow
                    cell.accessoryType = .none
                    cell.textLabel?.text = "Dark/Light Mode"
                    cell.detailTextLabel?.text = "Enable/Disable dark mode"
                case 1:
                    cell.textLabel?.text = "Change Email"
                    cell.detailTextLabel?.text = "Update your email address"
                case 2:
                    cell.textLabel?.text = "Change Password"
                    cell.detailTextLabel?.text = "Update your password"
                case 3:
                    cell.textLabel?.text = "Change Interests"
                    cell.detailTextLabel?.text = "Update your interests"
                case 4:
                    cell.textLabel?.text = "Tickets"
                    cell.detailTextLabel?.text = "View your tickets"
                case 5:
                    cell.textLabel?.text = "Log Out"
                    cell.detailTextLabel?.text = "Log out of your account"
                default:
                    break
                }
            }
            
            
        }
        return cell
    }
    
}
