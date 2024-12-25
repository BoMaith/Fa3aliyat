////
////  ChangeEmailViewController.swift
////  Fa3aliyat
////
////  Created by BP on 25/12/2024.
////
//
//import UIKit
//
//class ChangeEmailViewController: UIViewController {
//    
//    //adding all the input fields outlets
//    @IBOutlet weak var newEmailTextField: UITextField!
//    @IBOutlet weak var confirmNewEmailTextField: UITextField!
//    @IBOutlet weak var currentPassTextField: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//    //a fucntion to validate input
//    func vlaidateinput() {
//        //checking if the input fields are empty
//        guard let newEmail = newEmailTextField.text, let confirmNewEmail = confirmNewEmailTextField.text, let currentPass = currentPassTextField.text, !newEmail.isEmpty && !confirmNewEmail.isEmpty && !currentPass.isEmpty 
//        else
//        {
//            //creating an alert for when the input fields are empty
//            let alert = UIAlertController(title: "", message: <#T##String?#>, preferredStyle: <#T##UIAlertController.Style#>)
//        }
//    }
//
//}


//***************************************************TESTING TESTING TESTING***********************************************************
import UIKit
import FirebaseAuth
import FirebaseDatabase

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
        
        // Validate password length
        guard isValidPassword(currentPass) else {
            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
            return false
        }
        
        return true
    }
    
    // Function to change email
    @IBAction func changeEmailButtonTapped(_ sender: UIButton) {
        guard validateInput() else { return }
        
        guard let currentPass = currentPassTextField.text,
              let newEmail = newEmailTextField.text else { return }
        
        // Reauthenticate user
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPass)
        
        user?.reauthenticate(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "Re-authentication failed: \(error.localizedDescription)")
                return
            }
            
            // Update email in Firebase Authentication
            user?.updateEmail(to: newEmail) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Email update failed: \(error.localizedDescription)")
                    return
                }
                
                // Update email in Firebase Realtime Database
                let ref = Database.database().reference()
                ref.child("users").child(user?.uid ?? "").updateChildValues(["Email": newEmail]) { error, _ in
                    if let error = error {
                        self.showAlert(title: "Error", message: "Failed to update email in database: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Success", message: "Email updated successfully!")
                    }
                }
            }
        }
    }
    
    // Helper Functions for Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
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
