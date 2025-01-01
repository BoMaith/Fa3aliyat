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
    var eventID: String?
    var isEditingEvent: Bool = false
    var isNavigatingToCategory = false // Flag to not clear data when adding category
    var eventTitle: String?
    var eventDescription: String?
    var eventLocation: String?
    var eventPrice: String?
    var eventAge: String?

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
        
        // For editing
        if isEditingEvent, let eventID = eventID {
            loadEventDetails(eventID: eventID)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNavigatingToCategory {
            // Restore saved state when returning from category selection
            titleTextFeild.text = eventTitle
            descritionTextField.text = eventDescription
            locationTextField.text = eventLocation
            priceTextField.text = eventPrice
            ageTextField.text = eventAge
        } else {
            refreshPage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isNavigatingToCategory {
            // Save current state only when navigating to category selection
            eventTitle = titleTextFeild.text
            eventDescription = descritionTextField.text
            eventLocation = locationTextField.text
            eventPrice = priceTextField.text
            eventAge = ageTextField.text
        }
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
    
    func loadEventDetails(eventID: String) {
        let ref = Database.database().reference()
        ref.child("events").child(eventID).observeSingleEvent(of: .value) { snapshot in
            guard let eventData = snapshot.value as? [String: Any] else {
                print("Error: Unable to load event data.")
                return
            }
            
            DispatchQueue.main.async {
                self.titleTextFeild.text = eventData["title"] as? String ?? ""
                self.descritionTextField.text = eventData["description"] as? String ?? ""
                self.locationTextField.text = eventData["location"] as? String ?? ""
                self.priceTextField.text = "\(eventData["price"] as? Double ?? 0.0)"
                self.ageTextField.text = "\(eventData["age"] as? Int ?? 0)"
                self.selectedCategory = eventData["category"] as? String ?? "Uncategorized"
                
                if let imageURL = eventData["imageURL"] as? String, let url = URL(string: imageURL) {
                    self.imageURL = imageURL
                    self.loadImage(from: url)
                } else {
                    self.eventImageView.image = UIImage(named: "placeholder") // Use a placeholder image
                }
            }
        }
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Error: Unable to load image data.")
                return
            }
            DispatchQueue.main.async {
                self.eventImageView.image = image
            }
        }.resume()
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
           if let selectedImage = info[.editedImage] as? UIImage {
               eventImageView.image = selectedImage // Display the selected image
           }
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
           print("Image selection canceled.")
       }

       func validateInputs() -> Bool {
           if titleTextFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
               descritionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
               locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
               priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ||
               ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
               return false
           }
           if eventImageView.image == nil {
               showImageSelectionError()
               return false
           }
           return true
       }


    @IBAction func doneBtnTapped(_ sender: Any) {
        guard validateInputs() else {
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
        let eventId = isEditingEvent ? (self.eventID ?? UUID().uuidString) : (ref.child("events").childByAutoId().key ?? UUID().uuidString)
        
        // Formatters for  the time and dates
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "dd/MM/yyyy"
        //create a string to display in the home
        let startDateString = dateFormatter.string(from: startDatePicker.date)
        let endDateString = dateFormatter.string(from: endDatePicker.date)
        let dateRangeString = "\(startDateString) - \(endDateString)"
        
        let age = Int(ageTextField.text ?? "0") ?? 0
        let price = Double(priceTextField.text ?? "0") ?? 0.0
        
        // Collect event data
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
            "category": selectedCategory ?? "Uncategorized"
        ]
        
        //formatted `date` field during updates
        if isEditingEvent {
            let formattedDate = dateRangeString
            eventData["date"] = formattedDate
            
        }
        
        // Handle image upload
        if let selectedImage = eventImageView.image, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("events/\(eventId).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting image URL: \(error.localizedDescription)")
                    } else if let downloadURL = url?.absoluteString {
                        eventData["imageURL"] = downloadURL
                        self.saveEventToDatabase(ref: ref, organizerId: organizerId, eventId: eventId, eventData: eventData)
                    }
                }
            }
        } else {
            // If no new image is uploaded, save the event directly
            if let existingImageURL = self.imageURL {
                eventData["imageURL"] = existingImageURL
            }
            self.saveEventToDatabase(ref: ref, organizerId: organizerId, eventId: eventId, eventData: eventData)
        }
    }

       //save data to firebase
    private func saveEventToDatabase(ref: DatabaseReference, organizerId: String, eventId: String, eventData: [String: Any]) {
        let updates: [String: Any] = [
            "/events/\(eventId)": eventData,
            "/organizers/\(organizerId)/Events/\(eventId)": eventData
        ]
        
        ref.updateChildValues(updates) { [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                print("Error saving event: \(error.localizedDescription)")
            } else {
                print("Event successfully saved to Firebase. Event data: \(eventData)")
                self.showConfirmAlertAndNavigate()
            }
        }
    }
//displays a popup for successs and navigates back to home page
       
       func showConfirmAlertAndNavigate() {
           let message = isEditingEvent ? "Event updated successfully!" : "Event created successfully!"
           let alert = UIAlertController(
               title: "Success",
               message: message,
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               self.navigateToOrganizer()
           }))
           self.present(alert, animated: true, completion: nil)
       }
       // function to take the user to the organizer storyboard its called in te previous func
       func navigateToOrganizer() {
           let storyboard = UIStoryboard(name: "Organizer", bundle: nil)
           guard let organizerViewController = storyboard.instantiateInitialViewController() else {
               print("Error: Could not load Organizer storyboard.")
               return
           }
           organizerViewController.modalPresentationStyle = .fullScreen
           self.present(organizerViewController, animated: true, completion: nil)
       }
    
    
// functions for category selection
    // funcion for the segue to the category page
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ShowCategoriesForEvent", let destinationVC = segue.destination as? CategoriesViewController {
               isNavigatingToCategory = true
               destinationVC.delegate = self
               destinationVC.mode = .choose
           } else {
               isNavigatingToCategory = false
           }
       }
        // func to assign selected category to event
       func didSelectCategory(_ category: String) {
           selectedCategory = category
           print("Selected category for the event: \(category)")
       }
   }
