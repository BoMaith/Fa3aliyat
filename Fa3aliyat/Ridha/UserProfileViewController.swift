import UIKit

class UserProfileViewController: UIViewController {

    // Outlets for user profile information
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    // This property will hold the user data passed from the previous screen
    var userData: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Display user data if available
        if let user = userData {
            nameLabel.text = user["FullName"] as? String ?? "Unknown"
            emailLabel.text = user["email"] as? String ?? "Unknown"
        }
    }
}
