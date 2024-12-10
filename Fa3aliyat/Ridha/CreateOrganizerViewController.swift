import UIKit

protocol CreateOrganizerDelegate: AnyObject {
    func didCreateOrganizer(_ organizer: UsersPageViewController.Organizer)
}

class CreateOrganizerViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    weak var delegate: CreateOrganizerDelegate?
    var selectedImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        
    }



    @IBAction func createOrganizer(_ sender: Any) {
        // Step 1: Validate the name, email, and password fields
            guard let name = nameTextField.text, !name.isEmpty else {
                showAlert(message: "Please enter a name.")
                return
            }
            
            guard let email = emailTextField.text, !email.isEmpty else {
                showAlert(message: "Please enter an email.")
                return
            }
            
            // Validate email format
            if !isValidEmail(email) {
                showAlert(message: "Please enter a valid email address.")
                return
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                showAlert(message: "Please enter a password.")
                return
            }
            
            // Validate password strength (e.g., at least 6 characters)
            if password.count < 6 {
                showAlert(message: "Password must be at least 6 characters long.")
                return
            }
            
            // Step 2: Check if an image is selected
            guard let selectedImage = imageView.image else {
                showAlert(message: "Please select an image.")
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
                // Create a new organizer object with image
                let newOrganizer = UsersPageViewController.Organizer(
                    name: name,
                    email: email,
                    image: selectedImage // Pass the image here
                )
                
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


    // Function to validate email format using regular expression
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression to validate email format
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    // Function to show alerts
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    // Method to check if all fields are filled
    @objc func updateCreateButtonState() {
        // Check if all fields are non-empty
        let nameFilled = !(nameTextField.text?.isEmpty ?? true)
        let emailFilled = !(emailTextField.text?.isEmpty ?? true)
        let passwordFilled = !(passwordTextField.text?.isEmpty ?? true)
        
        // Enable or disable the "Create" button based on the state of all fields
        createButton.isEnabled = nameFilled && emailFilled && passwordFilled
    }


    // UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Update button state every time a character is typed or deleted
        updateCreateButtonState()
        return true
    }
    @objc func imageTapped() {
        presentImagePicker()
    }
    func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary  // Open the photo library
        imagePickerController.mediaTypes = ["public.image"]  // Only allow image selection
        
        // Present the image picker
        self.present(imagePickerController, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image  // Save the selected image
            imageView.image = image  // Display the image in the image view
        }
        dismiss(animated: true, completion: nil)  // Dismiss the picker
    }

    // This delegate method is called when the user cancels the image picker
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)  // Dismiss the picker without selecting an image
    }
    // Show an alert with the given message
    

    
    
    
    
    
    
    
}
