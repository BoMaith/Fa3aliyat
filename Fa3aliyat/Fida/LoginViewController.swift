//
//  LoginViewController.swift
//  Fa3aliyat
//
//  Created by Guest User on 10/12/2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //admin : admin@gmail.com, password : 
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text ,let password = passwordTextField.text ,
              !email.isEmpty && !password.isEmpty
        else{
            
            let alert = UIAlertController(title: "Missing input", message: "Email and password fields can not be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .cancel))
            self.present(alert, animated: true)
            return
            
        }
        
        //Firebase Authentication Part
        Auth.auth().signIn(withEmail: email, password: password , completion:{(result, error) in
            guard error == nil else {
                
                let alert = UIAlertController(title: "Login Failed", message: "Wrong Email or Password", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Try again", style: .cancel))
                self.present(alert, animated: true)
                return
                
            }
            
            //using if else statement to check the user type and then taking them to their respective pages
            if email.contains("admin"){
                self.performSegue(withIdentifier: "goToAdminHome", sender: sender)
            } else if email.contains("organizer"){
                self.performSegue(withIdentifier: "goToOrgHome", sender: sender)
            }else {
                self.performSegue(withIdentifier: "goToUserHome", sender: sender)
            }
            

        }
        
    
    
//    private func showAlert(title: String, message: String){
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//        }
   )}
}
