import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //function for when the login button is tapped
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if validateFields() {
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            
            //
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                    return
                }
                self.handleUserRedirection()
            }
        }
    }
    
    //functino for handling user redirection
    func handleUserRedirection() {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }
        
        //        if email.contains("@fa3aliyat.admin.bh") {
        //            self.performSegue(withIdentifier: "goToAdminHome", sender: self)
        //        } else if email.contains("@fa3aliyat.organizer.bh") {
        //            self.performSegue(withIdentifier: "goToOrgHome", sender: self)
        //        } else {
        //            self.performSegue(withIdentifier: "goToUserHome", sender: self)
        //        }
        
        //uaing if else statement to filter out the users based on their emails
        if email.contains("@fa3aliyat.admin.bh") {
            UserDefaults.standard.set("goToAdminHome", forKey: "last_visited_page")
            self.performSegue(withIdentifier: "goToAdminHome", sender: self)
        } else if email.contains("@fa3aliyat.organizer.bh") {
            UserDefaults.standard.set("goToOrgHome", forKey: "last_visited_page")

            self.performSegue(withIdentifier: "goToOrgHome", sender: self)
        } else {
            UserDefaults.standard.set("goToUserHome", forKey: "last_visited_page")
            self.performSegue(withIdentifier: "goToUserHome", sender: self)
        }
    }
    
    //a function for input validation
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
    
    //functions for having valid email and password
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //making a function to make sure thet the password lenght is 6 or biggeer than 6
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    //helper function for the alert to make my life easier
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
