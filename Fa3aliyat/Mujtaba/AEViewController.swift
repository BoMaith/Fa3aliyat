//
//  AEViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 17/12/2024.
//

import UIKit
import Firebase

class AEViewController:  UIViewController{
    
    // Outlets
    @IBOutlet weak var titleTextFeild: UITextField!
    @IBOutlet weak var descritionTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        saveEvent()
    }
    
    
    func saveEvent(){
        //refrence for the firbase
        let ref = Database.database().reference()
        
        // this is to format the date and time values
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
         
        //Collect data from text fields and pickers
        let eventData: [String: Any] = [
            "title": titleTextFeild.text ?? "",
            "description": descritionTextField.text ?? "",
            "time": formatter.string(from: timePicker.date),
            "Location": locationTextField.text ?? "",
            "startDate": formatter.string(from: startDatePicker.date),
            "endDate": formatter.string(from: endDatePicker.date),
            "price": priceTextField.text ?? "",
            "Age": ageTextField.text ?? ""
        ]
        // saving the event with an ID
        ref.child("events").childByAutoId().setValue(eventData){ error, _ in
            if let error = error {
                print("Error saving event to Firebase: \(error.localizedDescription)")
            } else {
                print("Event Created.")
                self.showConfirmAlert()
            }
            
        }
    }
    
    func showConfirmAlert() {
        let alert = UIAlertController(title:"Success", message: "Event Created.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

