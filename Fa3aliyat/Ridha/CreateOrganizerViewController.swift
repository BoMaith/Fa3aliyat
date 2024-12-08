import UIKit

// Define the protocol for passing data back to UsersPageViewController
protocol CreateOrganizerDelegate: AnyObject {
    func didCreateOrganizer(_ organizer: UsersPageViewController.Organizer)
}

class CreateOrganizerViewController: UIViewController {

    // Step 1: Declare a delegate property
    weak var delegate: CreateOrganizerDelegate?

    // Outlets for the text fields for the organizer's name and email
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Any additional setup can go here if needed.
    }

    // This action is triggered when the user clicks the "Create Organizer" button
    @IBAction func createOrganizer(_ sender: Any) {
        // Step 2: Validate the name and email fields
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            // Show an alert if name or email is empty
            let alert = UIAlertController(title: "Error", message: "Please fill in both the name and email fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Step 3: Show a confirmation alert
        let alertController = UIAlertController(
            title: "Create Organizer",
            message: "Are you sure you want to create an organizer account?",
            preferredStyle: .alert
        )
        
        // Step 4: Define the actions for the alert
        let okAction = UIAlertAction(title: "Sure", style: .default) { _ in
            // Create a new organizer object
            let newOrganizer = UsersPageViewController.Organizer(name: name, email: email)
            
            // Step 5: Send the new organizer back to the delegate (UsersPageViewController)
            self.delegate?.didCreateOrganizer(newOrganizer)
            
            // Step 6: Pop back to the previous view controller
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Not Really", style: .cancel, handler: nil)

        // Step 7: Add actions to the alert
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Step 8: Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
}
