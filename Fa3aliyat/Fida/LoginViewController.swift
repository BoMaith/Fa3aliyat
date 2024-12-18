import UIKit
import FirebaseAuth
import FirebaseDatabase // For Firebase Realtime Database

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty && !password.isEmpty else {
            let alert = UIAlertController(title: "Missing Input", message: "Email and password fields cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        
        // Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            guard error == nil, let user = result?.user else {
                let alert = UIAlertController(title: "Login Failed", message: "Wrong Email or Password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel))
                strongSelf.present(alert, animated: true)
                return
            }
            
            // Firebase Realtime Database reference
            let databaseRef = Database.database().reference()
            
            // Check if this is the user's first login
            databaseRef.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any] {
                    // Safely cast isFirstLogin to a Bool using type checks
                    let isFirstLogin = userData["isFirstLogin"] as? Bool ?? false
                    print("isFirstLogin value: \(isFirstLogin)") // Debugging output
                    
                    if isFirstLogin == true {
                        // If isFirstLogin is true, go to Interests Page
                        strongSelf.performSegue(withIdentifier: "goToInterests", sender: sender)
                        
                        // Update the flag in the database to false
                        databaseRef.child("users").child(user.uid).updateChildValues(["isFirstLogin": false])
                    } else {
                        // Handle navigation for existing users
                        if email.contains("admin") {
                            strongSelf.performSegue(withIdentifier: "goToAdminHome", sender: sender)
                        } else if email.contains("organizer") {
                            strongSelf.performSegue(withIdentifier: "goToOrgHome", sender: sender)
                        } else {
                            strongSelf.performSegue(withIdentifier: "goToUserHome", sender: sender)
                        }
                    }
                }
            }
        }
    }
}
