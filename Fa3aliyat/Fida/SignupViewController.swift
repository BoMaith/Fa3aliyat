import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignupViewController: UIViewController {
    
    // Declaring variables (outlets for each text fields)
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional setup after loading the view
    }
    
    // Function for when the register button is clicked
    @IBAction func registerButtonClicked(_ sender: Any) {
        // Using guard let to validate input
        guard let fullName = fullNameTextField.text,
              let userName = userNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              !fullName.isEmpty, !userName.isEmpty,
              !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Input", message: "Fields cannot be empty")
            return
        }
        
        // Validate email and password
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        
        guard isValidPassword(password) else {
            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long")
            return
        }
        
        // Firebase Authentication
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "SignUp Failed: \(error.localizedDescription)")
                return
            }
            
            // Save user details to Firebase Realtime Database
            guard let user = result?.user else {
                self.showAlert(title: "Error", message: "User creation failed.")
                return
            }
            
            // Making a unique ID for each user
            let uid = user.uid
            // Getting the database reference
            let ref = Database.database().reference()
            
            // An array list of string with all the attributes and their types
            let userInfo: [String: Any] = [
                "FullName": fullName,
                "UserName": userName,
                "Email": email,
                "Password": password
            ]
            
            // Making an entry in the database
            ref.child("users").child(uid).setValue(userInfo) { error, _ in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                    return
                }
                
                let alert = UIAlertController(title: "Success", message: "Account created successfully!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    UserDefaults.standard.set(Auth.auth().currentUser!.uid, forKey: "user_uid_key")
                    
                    if email.contains("@fa3aliyat.admin.bh") {
                        UserDefaults.standard.set("AdminHomeViewController", forKey: "last_visited_page")
                        self.performSegue(withIdentifier: "goToInterests", sender: nil)
                    } else if email.contains("@fa3aliyat.organizer.bh") {
                        UserDefaults.standard.set("OrganizerHomeViewController", forKey: "last_visited_page")
                        self.performSegue(withIdentifier: "goToInterests", sender: nil)
                    } else {
                        UserDefaults.standard.set("UserHomeViewController", forKey: "last_visited_page")
                        self.performSegue(withIdentifier: "goToInterests", sender: nil)
                    }
                })
                self.present(alert, animated: true)
            }

        }
    }
    
    // Helper Functions for Validation of email which ensures that the email has the following things
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        if email.contains("@fa3aliyat.organizer.bh") || email.contains("@fa3aliyat.admin.bh") {
            showAlert(title: "Sign up failed", message: "An admin can only create an organizer or admin account.")
            return false
        }
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // A function to ensure that the password length is 6 or more than 6
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // A helper function for the alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
