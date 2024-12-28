//
//  AEViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 17/12/2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class AEViewController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoriesViewControllerDelegate {
    
    // Outlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleTextFeild: UITextField!
    @IBOutlet weak var descritionTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    var selectedCategory: String? // To store the chosen category
        var imageURL: String? // To store the uploaded image URL
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Make the image circular
            eventImageView.layer.cornerRadius = eventImageView.frame.size.width / 2
            eventImageView.clipsToBounds = true
            eventImageView.contentMode = .scaleAspectFill
            
            // Enable interaction for the image view
            eventImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            eventImageView.addGestureRecognizer(tapGesture)
        }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            refreshPage()
        }
        
        func refreshPage() {
            // Clear all fields and reset UI
            titleTextFeild.text = ""
            descritionTextField.text = ""
            locationTextField.text = ""
            priceTextField.text = ""
            ageTextField.text = ""
            eventImageView.image = nil // Reset the image
            selectedCategory = nil // Reset selected category
            startDatePicker.date = Date() // Set to current date
            endDatePicker.date = Date()
            timePicker.date = Date() // Set time to current
            
        }

        func showValidationError() {
            let alert = UIAlertController(
                title: "Failed",
                message: "Please Fill ALL Fields.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        func showImageSelectionError() {
            let alert = UIAlertController(
                title: "Image Missing",
                message: "Please select an image for the event.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary  // Opens the photo library
                picker.allowsEditing = true       // Allow users to crop the image
                present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Get the selected image
        if let selectedImage = info[.editedImage] as? UIImage {
            eventImageView.image = selectedImage // Display the selected image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image selection canceled.")
    }

    func validateInputs() -> Bool {
        // Check if any field is empty
        if titleTextFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
            descritionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
            locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
            priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
            ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            return false
        }
        
        // Check if an image is selected
        if eventImageView.image == nil {
            showImageSelectionError()
            return false
        }
        
        return true
    }


    @IBAction func doneBtnTapped(_ sender: Any) {
        guard validateInputs() else{
            showValidationError()
            return
        }
        saveEvent()
    }
    
    func saveEvent() {
            guard let organizerId = Auth.auth().currentUser?.uid else {
                print("Organizer ID not found.")
                return
            }
            
            let ref = Database.database().reference()
            
            // Format the time and dates
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.dateFormat = "dd/MM/yyyy"
            
            let startDateString = dateFormatter.string(from: startDatePicker.date)
            let endDateString = dateFormatter.string(from: endDatePicker.date)
            let dateRangeString = "\(startDateString) - \(endDateString)"
            
            let age = Int(ageTextField.text ?? "0") ?? 0
            let price = Double(priceTextField.text ?? "0") ?? 0.0
            
            // Collect core event data
            var eventData: [String: Any] = [
                "title": titleTextFeild.text ?? "",
                "description": descritionTextField.text ?? "",
                "time": timeFormatter.string(from: timePicker.date),
                "location": locationTextField.text ?? "",
                "startDate": fullDateFormatter.string(from: startDatePicker.date),
                "endDate": fullDateFormatter.string(from: endDatePicker.date),
                "date": dateRangeString,
                "price": price,
                "age": age,
                "participants": [],
                "category": selectedCategory ?? "Uncategorized"
            ]
            
            // Generate an event ID
            let eventId = ref.child("events").childByAutoId().key ?? UUID().uuidString
            
            // Check if an image is selected
            if let selectedImage = eventImageView.image, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("events/\(eventId).jpg")
                
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                    
                    // Get the download URL
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else if let downloadURL = url?.absoluteString {
                            eventData["imageURL"] = downloadURL
                            self.saveEventToDatabase(ref: ref, organizerId: organizerId, eventId: eventId, eventData: eventData)
                        }
                    }
                }
            }
        }

        private func saveEventToDatabase(ref: DatabaseReference, organizerId: String, eventId: String, eventData: [String: Any]) {
            let updates: [String: Any] = [
                "/events/\(eventId)": eventData,
                "/organizers/\(organizerId)/Events/\(eventId)": eventData
            ]
            
            ref.updateChildValues(updates) { error, _ in
                if let error = error {
                    print("Error saving event: \(error.localizedDescription)")
                } else {
                    print("Event created successfully!")
                    self.showConfirmAlert()
                }
            }
        }

        func showConfirmAlert() {
            let alert = UIAlertController(
                title: "Success",
                message: "Event Created.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowCategoriesForEvent", let destinationVC = segue.destination as? CategoriesViewController {
                destinationVC.mode = .choose // Set mode for choosing a category
                destinationVC.delegate = self // Set the delegate
            }
        }

        func didSelectCategory(_ category: String) {
            selectedCategory = category
            print("Selected category for the event: \(category)")
        }
    }

