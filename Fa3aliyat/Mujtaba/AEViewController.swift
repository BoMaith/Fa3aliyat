//
//  AEViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 17/12/2024.
//

import UIKit
import Firebase
import FirebaseAuth

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
    func showValidationError() {
        let alert = UIAlertController(title:"Failed", message: "Please Fill ALL Fields.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

    @IBAction func doneBtnTapped(_ sender: Any) {
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
        }
        return true
    }
    
    
    func saveEvent(){
        
        //getting organizer Id
        guard let organizerId = Auth.auth().currentUser?.uid else {
            print("organizer Id not found")
            return
        }
        
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
        
        //convert age to int
        let age = Int(ageTextField.text ?? "0") ?? 0
        
        //make price a double value
        let price = Double(priceTextField.text ?? "0") ?? 0.0
        
        //Collect data from text fields and pickers
        let eventData: [String: Any] = [
            "title": titleTextFeild.text ?? "",
            "description": descritionTextField.text ?? "",
            "time": timeFormatter.string(from: timePicker.date),
            "Location": locationTextField.text ?? "",
            "startDate": fullDateFormatter.string(from: startDatePicker.date),
            "endDate": fullDateFormatter.string(from: endDatePicker.date),
            "date": dateRangeString,
            "price": price,
            "Age": age,
            "participants": []
            //"ratings":
        ]
        
        //gen eventID
        let eventId = ref.child("events").childByAutoId().key ?? UUID().uuidString
        
        //to help saving in events list and organizer lists which helps us in filtering organizers events when needed
        
        let update: [String: Any] = [
            "/events/\(eventId)": eventData,
            "/organizers/\(organizerId)/Events/\(eventId)" : eventData
        ]
        
        // saving the event in both lists
        ref.updateChildValues(update){ error, _ in
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

