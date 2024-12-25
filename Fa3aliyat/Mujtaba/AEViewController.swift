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
    
    @IBAction func doneBtnTapped() {
        guard validateInputs() else{
            showValidationError()
            return
        }
        saveEvent()
    }
     
    func validateInputs() -> Bool{
        //check if any field is left empty
        if titleTextFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true || descritionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true || locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true || priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true || ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            return false
        } else {
            return true
        }
    }
    
    
    func saveEvent(){
        //refrence for the firbase
        let ref = Database.database().reference()
        
        // this is to format the date and time values
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        // formats for single dates
        let sDateFormatter = DateFormatter()
        sDateFormatter.dateFormat = "MMM d"
        
        //setting ranges for dates for event displays
        let startDateString = sDateFormatter.string(from: startDatePicker.date)
        let endDateString = sDateFormatter.string(from: endDatePicker.date)
        let dateRangeString = "\(startDateString) - \(endDateString)"
        
        // formatter for full dates just for storing data from start and end dates
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "dd-MM-yyyy"
        
        //Collect data from text fields and pickers
        let eventData: [String: Any] = [
            "title": titleTextFeild.text ?? "",
            "description": descritionTextField.text ?? "",
            "time": timeFormatter.string(from: timePicker.date),
            "Location": locationTextField.text ?? "",
            "startDate": fullDateFormatter.string(from: startDatePicker.date),
            "endDate": fullDateFormatter.string(from: endDatePicker.date),
            "date": dateRangeString,
            "price": priceTextField.text ?? "",
            "Age": ageTextField.text ?? "",
            "isFavorite": false
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
    func showValidationError() {
        let alert = UIAlertController (title:"Missing info.", message: "PLease input all the information to create the Event", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
    }
    
    
}

