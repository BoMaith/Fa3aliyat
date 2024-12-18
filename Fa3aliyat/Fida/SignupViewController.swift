////
////  SignupViewController.swift
////  Fa3aliyat
////
////  Created by BP-36-201-09 on 12/12/2024.
////
//
import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignupViewController: UIViewController {
    
    //declaring variables (outlets for each text fields)
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //function for when the register button is clicked
    @IBAction func registerButtonClicked(_ sender: Any) {
        //using guard let to validate input
        guard let fullName = fullNameTextField.text,
              let userName = userNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              !fullName.isEmpty && !userName.isEmpty &&
                !email.isEmpty && !password.isEmpty
        else {
            //showing alerts if the input data is not empty
            let alert = UIAlertController(title: "Missing input", message: "Fields can not be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .cancel))
            self.present(alert, animated: true)
            return
        }//else ended
        
        // Firebase Authentication
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] Result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "SignUp Failed: \(error.localizedDescription)")
                return
            }
            
            // Save user details to Firebase Realtime Database
            guard let user = Result?.user else {
                self.showAlert(title: "Error", message: "User creation failed.")
                return
            }
            
            //making a unique id for each user (copy pasted from the document)
            let uid = user.uid
            //getting the database reference
            let ref = Database.database().reference()
            
            //an array list of string with all the attributes and their types
            let userInfo: [String: Any] = [
                "FullName": fullName,
                "UserName": userName,
                "Email": email,
                "Password" : password,
                "isnew": true
            ]
            
            //making an entry in the database
            ref.child("users").child(uid).setValue(userInfo) { error, _ in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(title: "Success", message: "Account created successfully!")
                
                //navigate to the interests page
                self.performSegue(withIdentifier: "goToInterests", sender: sender)
            }
        })
    }
    
    // Helper Functions for Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    //a function to ensure that the password lenght is 6 or more than 6
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    //checking if the phone number is valid
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[0-9]{8}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
    }
    
    //a helper fuction for the alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
//
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    */
//
//

