import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var tableview: UITableView!

    @IBAction func logoutButtonTapped(_ sender: Any) {
        // Code to handle logout will go here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "showChangeEmail", sender: self)
        case 1:
            performSegue(withIdentifier: "showChangePassword", sender: self)
        case 2:
            performSegue(withIdentifier: "showChangeInterests", sender: self)
        case 3:
            performSegue(withIdentifier: "showTickets", sender: self)
        case 4:
            // Handle logout here
            break
        default:
            break
        }
    }
}

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We have one section in our table
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 // We have five rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        // Show the right text and subtitle for each row
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Change Email"
            cell.detailTextLabel?.text = "Update your email address"
        case 1:
            cell.textLabel?.text = "Change Password"
            cell.detailTextLabel?.text = "Update your password"
        case 2:
            cell.textLabel?.text = "Change Interests"
            cell.detailTextLabel?.text = "Update your interests"
        case 3:
            cell.textLabel?.text = "Tickets"
            cell.detailTextLabel?.text = "View your tickets"
        case 4:
            cell.textLabel?.text = "Log out"
            cell.detailTextLabel?.text = "Log out of your account"
        default:
            break
        }

        return cell
    }
}
