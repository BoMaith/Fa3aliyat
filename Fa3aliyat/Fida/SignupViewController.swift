//
//  SignupViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-201-09 on 12/12/2024.
//

import UIKit

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
    
    
    //making a function to validate inputs using if else and guard statements
    func validateInput(){
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
    }//function ended
    
    //function for when the register button is clicked
    @IBAction func registerButtonClicked(_ sender: Any) {
        validateInput()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
