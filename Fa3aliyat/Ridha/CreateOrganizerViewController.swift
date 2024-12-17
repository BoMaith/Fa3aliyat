import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol CreateOrganizerDelegate: AnyObject {
    func didCreateOrganizer(_ organizerData: [String: Any])
}

class CreateOrganizerViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var delegate: CreateOrganizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never

        // Set the delegate for the text fields
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Initially, disable the "Create" button
        createButton.isEnabled = false
        
        // Add target for 'editingChanged' event on each text field
        nameTextField.addTarget(self, action: #selector(updateCreateButtonState), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(updateCreateButtonState), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(updateCreateButtonState), for: .editingChanged)
    }
    
    // MARK: - Button Actions
    @IBAction func createOrganizer(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a name.")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter an email.")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(title: "Error", message: "Please enter a valid email address.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter a password.")
            return
        }
        
        if password.count < 6 {
            showAlert(title: "Error", message: "Password must be at least 6 characters long.")
            return
        }
        
        // Create a user in Firebase Authentication first
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to create user: \(error.localizedDescription)")
                return
            }
            
            // User created successfully, now save the organizer data in Firebase Realtime Database
            if let uid = result?.user.uid {
                let ref = Database.database().reference()
                
                // Create a new reference for the organizer in Firebase Realtime Database
                let newOrganizerRef = ref.child("organizers").child(uid)
                
                let organizerData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "password": password,  // Storing password directly is not recommended in production
                    "uid": uid
                ]
                
                // Save organizer data to Firebase Realtime Database
                newOrganizerRef.setValue(organizerData) { error, _ in
                    if let error = error {
                        self.showAlert(title: "Error", message: "Failed to save organizer data: \(error.localizedDescription)")
                        return
                    }
                    
                    // Show success alert and navigate back
                    self.showAlert(title: "Success", message: "Organizer created successfully!") {
                        // Optionally notify the delegate if needed
                        self.delegate?.didCreateOrganizer(organizerData)
                        
                        // Navigate back to the main page after success
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the "OK" button
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateCreateButtonState() {
        let nameFilled = !(nameTextField.text?.isEmpty ?? true)
        let emailFilled = !(emailTextField.text?.isEmpty ?? true)
        let passwordFilled = !(passwordTextField.text?.isEmpty ?? true)
        
        createButton.isEnabled = nameFilled && emailFilled && passwordFilled
    }
}
