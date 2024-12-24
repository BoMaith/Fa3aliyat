//
//  ChangeEmailViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-14 on 24/12/2024.
//

import UIKit

class ChangeEmailViewController: UIViewController {
    //all the outlets
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var confirmNewEmailTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //making a function for the input validation of type bool, so if the credentials work out, it will return true
    func validateInputFields() -> Bool
    {
        guard let newEmail = newEmailTextField.text, let confirmNewEmail = confirmNewEmailTextField.text, let currentPass = currentPasswordTextField.text, !newEmail.isEmpty && !confirmNewEmail.isEmpty && !currentPass.isEmpty else{
            showAlert(title: "Validation Error", message: "Email and Password cannot be empty.")
            return false
        }
        return true
    }
    
    
    
    
    
    
    
    
    
    //helper function for the alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        validateInputFields()
    }
    
}
