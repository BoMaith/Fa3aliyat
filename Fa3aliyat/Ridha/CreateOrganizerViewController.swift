import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol CreateOrganizerDelegate: AnyObject {
    func didCreateOrganizer(_ organizerData: [String: Any])
}

class CreateOrganizerViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailDomainLabel: UILabel!  // Label for the domain part
    
    weak var delegate: CreateOrganizerDelegate?
    
    // Fixed domain part of the email
    let emailDomain = "@fa3aliyat.organizer.bh"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        // Add a tap gesture recognizer to the profile image to trigger the image picker
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
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
        
        // Initially set the domain label to fixed text
        emailDomainLabel.text = emailDomain
        emailDomainLabel.textColor = .gray
    }
    
    // MARK: - Button Actions
    @IBAction func createOrganizer(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a name.")
            return
        }
        
        // Ensure the name is at least 3 characters long
        if name.count < 3 {
            showAlert(title: "Error", message: "Name must be at least 3 characters long.")
            return
        }
        
        guard let emailPrefix = emailTextField.text, !emailPrefix.isEmpty else {
            showAlert(title: "Error", message: "Please enter an email prefix.")
            return
        }
        
        // Validate that the email prefix does not include the domain part
        if emailPrefix.contains("@") {
            showAlert(title: "Error", message: "Please only enter the prefix (before the '@').")
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
        
        // Complete the email by appending the fixed domain
        let fullEmail = emailPrefix + emailDomain
        
        // Create a user in Firebase Authentication first
        FirebaseAuth.Auth.auth().createUser(withEmail: fullEmail, password: password) { [weak self] result, error in
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
                    "FullName": name,
                    "email": fullEmail,
                    "Password": password,  // Storing password directly is not recommended in production
                    
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
        let emailPrefixFilled = !(emailTextField.text?.isEmpty ?? true)
        let passwordFilled = !(passwordTextField.text?.isEmpty ?? true)
        
        createButton.isEnabled = nameFilled && emailPrefixFilled && passwordFilled
    }

    @objc func profileImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary // Or .camera if you want to allow taking a new photo

        // Present the image picker
        present(imagePickerController, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Set the selected image to the profileImage
            profileImage.image = selectedImage
        }

        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }

    // This method is called when the user cancels the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Simply dismiss the picker if the user cancels
        dismiss(animated: true, completion: nil)
    }
}
