	//
//  EventViewController.swift
//  Fa3aliyat
//
//  Created by Student on 12/12/2024.
//

import UIKit
import FirebaseDatabase

class EventViewController: UIViewController {
    
    @IBOutlet weak var orgImage: UIImageView!
    @IBOutlet weak var orgName: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Etitle: UILabel!
    @IBOutlet weak var Edescription: UILabel!
    @IBOutlet weak var Eprice: UILabel!
    @IBOutlet weak var Elocation: UILabel!
    @IBOutlet weak var Joinbtn: UIButton!
    @IBOutlet weak var AvgRate: UILabel!
    
    // Event ID for fetching data (hardcoded for testing)
    let eventID = "-OF3962vsncLEOoF3YPJ"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debugging
        print("EventViewController loaded with eventID: \(eventID)")
        
        // Fetch event details and ratings from Firebase
        fetchEventDetails(eventID: eventID)
        fetchAverageRating(eventID: eventID)
    }
    
    /// Fetches event details from Firebase for a given event ID
    func fetchEventDetails(eventID: String) {
        let ref = Database.database().reference()
        ref.child("events").child(eventID).observeSingleEvent(of: .value) { snapshot in
            print("Received snapshot: \(snapshot)") // Debugging output

            guard let eventData = snapshot.value as? [String: Any] else {
                print("Error: Unable to parse event data.")
                return
            }
            
            print("Event data: \(eventData)") // Debugging output
            
            // Extract only the relevant data and populate UI
            let date = eventData["date"] as? String ?? "N/A"
            let description = eventData["description"] as? String ?? "N/A"
            let title = eventData["title"] as? String ?? "N/A"
            let price = eventData["price"] as? Double ?? 0.0
            let orgImageURL = eventData["org-image"] as? String ?? ""
            let location = eventData["location"] as? String ?? "N/A"
            
            DispatchQueue.main.async {
                self.Date.text = date
                self.Etitle.text = title
                self.Edescription.text = description
                self.Eprice.text = "Price: \(price)BD" // Format the price
                self.orgName.text = title
                self.Elocation.text = "Location: \(location)"
                
                // Load organizer image
                if let url = URL(string: orgImageURL) {
                    self.loadImage(from: url)
                }
            }
        }
    }
    
    /// Fetches the average rating for a given event ID from Firebase
    func fetchAverageRating(eventID: String) {
        let ref = Database.database().reference()
        ref.child("events").child(eventID).child("reviews").observeSingleEvent(of: .value) { snapshot in
            var totalRating = 0
            var ratingCount = 0
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let reviewData = childSnapshot.value as? [String: Any],
                   let rating = reviewData["rating"] as? Int {
                    totalRating += rating
                    ratingCount += 1
                }
            }
            
            let averageRating = ratingCount == 0 ? 0.0 : Double(totalRating) / Double(ratingCount)
            DispatchQueue.main.async {
                self.AvgRate.text = String(format: "%.1f", averageRating)
            }
        }
    }
    
    /// Loads an image from a URL and sets it to the UIImageView
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
                self.orgImage.image = image
            }
        }.resume()
    }
    
    @IBAction func navigateToPayment(_ sender: Any) {
        //performSegue(withIdentifier: "toPayViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayViewController" {
            if let payVC = segue.destination as? PayViewController {
                payVC.eventID = self.eventID
            }
        }
    }
}
