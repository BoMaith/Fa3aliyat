import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChangeEmailViewController: UIViewController {
    
    // Adding all the input fields outlets
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var confirmNewEmailTextField: UITextField!
    @IBOutlet weak var currentPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view
    }
    
    // Function to validate input
    func validateInput() -> Bool {
        // Checking if the input fields are empty
        guard let newEmail = newEmailTextField.text,
              let confirmNewEmail = confirmNewEmailTextField.text,
              let currentPass = currentPassTextField.text,
              !newEmail.isEmpty, !confirmNewEmail.isEmpty, !currentPass.isEmpty else {
            showAlert(title: "Missing Input", message: "All fields are required.")
            return false
        }
        
        // Validate email format
        guard isValidEmail(newEmail) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return false
        }
        
        // Validate email confirmation
        guard newEmail == confirmNewEmail else {
            showAlert(title: "Email Mismatch", message: "Email addresses do not match.")
            return false
        }
        
        return true
    }
    
    // Function to change email
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard validateInput() else { return }
        
        guard let newEmail = newEmailTextField.text else { return }
        
        // Show confirmation alert
        let alert = UIAlertController(title: "Confirm Email Change", message: "Are you sure you want to change your email?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            // Update email in Firebase Realtime Database
            if let userID = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference()
                //updating the email value inside the real time database
                ref.child("users").child(userID).updateChildValues(["Email": newEmail]) { error, _ in
                    
                    if let error = error {
                        self.showAlert(title: "Error", message: "Failed to update email in database: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Success", message: "Email updated successfully!")
                    }
                }
            } else {
                self.showAlert(title: "Error", message: "No user is logged in.")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Helper Functions for Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // Helper function for alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
