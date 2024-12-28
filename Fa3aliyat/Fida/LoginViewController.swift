import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Function for when the login button is tapped
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if validateFields() {
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    self.showAlert(title: "Login Failed", message: "The email or password is incorrect.")
                    return
                }
                self.handleUserRedirection()
            }
        }
    }
    
    // Function to handle user redirection
    func handleUserRedirection() {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }
        
        if email.contains("@fa3aliyat.admin.bh") {
            UserDefaults.standard.set("AdminHomeViewController", forKey: "last_visited_page")
            self.performSegue(withIdentifier: "goToAdminHome", sender: self)
        } else if email.contains("@fa3aliyat.organizer.bh") {
            UserDefaults.standard.set("OrganizerHomeViewController", forKey: "last_visited_page")
            self.performSegue(withIdentifier: "goToOrgHome", sender: self)
        } else {
            UserDefaults.standard.set("UserHomeViewController", forKey: "last_visited_page")
            self.performSegue(withIdentifier: "goToUserHome", sender: self)
        }
    }

    
    // Function for input validation
    func validateFields() -> Bool {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Validation Error", message: "Email and Password cannot be empty.")
            return false
        }
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return false
        }
        if !isValidPassword(password) {
            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
            return false
        }
        return true
    }
    
    // Functions for having valid email and password
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Making a function to make sure the password length is 6 or bigger than 6
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // Helper function for the alert to make my life easier
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
