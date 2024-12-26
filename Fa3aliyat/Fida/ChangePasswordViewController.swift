//import UIKit
//import FirebaseDatabase
//import FirebaseAuth
//
//class ChangePasswordViewController: UIViewController {
//    
//    // Adding all the outlets
//    @IBOutlet weak var currentPasswordTextField: UITextField!
//    @IBOutlet weak var newPassTextField: UITextField!
//    @IBOutlet weak var confirmNewPassTextField: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Additional setup after loading the view
//    }
//    
//    // Function to validate user input
//    func validateUserInput() -> Bool {
//        // Guard statement to check if the input is empty, and showing errors when it is empty
//        guard let currentPass = currentPasswordTextField.text,
//              let newPass = newPassTextField.text,
//              let confirmNewPass = confirmNewPassTextField.text,
//              !currentPass.isEmpty, !newPass.isEmpty, !confirmNewPass.isEmpty else {
//            showAlert(title: "Missing Input", message: "All fields are required.")
//            return false
//        }
//        
//        // Validate password confirmation
//        guard newPass == confirmNewPass else {
//            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
//            return false
//        }
//        
//        // Validate password length
//        guard isValidPassword(newPass) else {
//            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
//            return false
//        }
//        
//        return true
//    }
//    
//    // Function to change password
//    @IBAction func submitButtonTapped(_ sender: UIButton) {
//        guard validateUserInput() else { return }
//        
//        guard let newPass = newPassTextField.text else { return }
//        
//        // Show confirmation alert
//        let alert = UIAlertController(title: "Confirm Password Change", message: "Are you sure you want to change your password?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
//            // Update password in Firebase Realtime Database
//            if let userID = Auth.auth().currentUser?.uid {
//                let ref = Database.database().reference()
//                // Updating the password value inside the real time database
//                ref.child("users").child(userID).updateChildValues(["Password": newPass]) { error, _ in
//                    
//                    if let error = error {
//                        self.showAlert(title: "Error", message: "Failed to update password in database: \(error.localizedDescription)")
//                    } else {
//                        self.showAlert(title: "Success", message: "Password updated successfully!")
//                    }
//                }
//            } else {
//                self.showAlert(title: "Error", message: "No user is logged in.")
//            }
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    // Helper Functions for Validation
//    
//    private func isValidPassword(_ password: String) -> Bool {
//        return password.count >= 6
//    }
//    
//    // Helper function for alerts
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}



//***************************************************************CO PILOT TEST***********************************************************************************************
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChangePasswordViewController: UIViewController {
    
    // Adding all the outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmNewPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view
    }
    
    // Function to validate user input
    func validateUserInput() -> Bool {
        // Guard statement to check if the input is empty, and showing errors when it is empty
        guard let currentPass = currentPasswordTextField.text,
              let newPass = newPassTextField.text,
              let confirmNewPass = confirmNewPassTextField.text,
              !currentPass.isEmpty, !newPass.isEmpty, !confirmNewPass.isEmpty else {
            showAlert(title: "Missing Input", message: "All fields are required.")
            return false
        }
        
        // Validate password confirmation
        guard newPass == confirmNewPass else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return false
        }
        
        // Validate password length
        guard isValidPassword(newPass) else {
            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
            return false
        }
        
        return true
    }
    
    // Function to change password
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard validateUserInput() else { return }
        
        guard let newPass = newPassTextField.text,
              let currentPass = currentPasswordTextField.text else { return }
        
        // Show confirmation alert
        let alert = UIAlertController(title: "Confirm Password Change", message: "Are you sure you want to change your password?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            // Reauthenticate user
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPass)
            
            user?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Re-authentication failed: \(error.localizedDescription)")
                    return
                }
                
                // Update password in Firebase Authentication
                user?.updatePassword(to: newPass) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: "Password update failed: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update password in Firebase Realtime Database
                    let ref = Database.database().reference()
                    ref.child("users").child(user?.uid ?? "").updateChildValues(["Password": newPass]) { error, _ in
                        if let error = error {
                            self.showAlert(title: "Error", message: "Failed to update password in database: \(error.localizedDescription)")
                        } else {
                            self.showAlert(title: "Success", message: "Password updated successfully!")
                        }
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Helper Functions for Validation
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // Helper function for alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
