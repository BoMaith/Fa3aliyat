	//
//  EventViewController.swift
//  Fa3aliyat
//
//  Created by Student on 12/12/2024.
//

import UIKit
import FirebaseDatabaseInternal

class EventViewController: UIViewController {
    
    
    @IBOutlet weak var orgImage: UIImageView!
    @IBOutlet weak var orgName: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Etitle: UILabel!
    @IBOutlet weak var Edescription: UILabel!
    @IBOutlet weak var Eprice: UILabel!
    @IBOutlet weak var Elocation: UILabel!
    @IBOutlet weak var Joinbtn: UIButton!
    
    // Event ID for fetching data (hardcoded for testing)
    let eventID = "7Z3DkLm2QwFjSx8Ny5VrHqPb9Nz1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debugging
        print("EventViewController loaded with eventID: \(eventID)")
        
        // Fetch event details from Firebase
        fetchEventDetails(eventID: eventID)
    }
    
    /// Fetches event details from Firebase for a given event ID
    func fetchEventDetails(eventID: String) {
        let ref = Database.database().reference()
        ref.child("events").child(eventID).observeSingleEvent(of: .value) { snapshot in
            guard let eventData = snapshot.value as? [String: Any] else {
                print("Error: Unable to parse event data.")
                return
            }
            
            // Extract data and populate UI
            let date = eventData["date"] as? String ?? "N/A"
            let description = eventData["description"] as? String ?? "N/A"
            let title = eventData["title"] as? String ?? "N/A"
            let price = eventData["price"] as? Double ?? 0.0
            let orgImageURL = eventData["org-image"] as? String ?? ""
            let organizerName = eventData["name"] as? String ?? "N/A"
            let location = eventData["location"] as? String ?? "N/A"
            
            DispatchQueue.main.async {
                self.Date.text = date
                self.Etitle.text = title
                self.Edescription.text = description
                self.Eprice.text = "Price: \(price)BD" // Format the price
                self.orgName.text = organizerName
                self.Elocation.text = "Location: \(location)"
                
                // Load organizer image
                if let url = URL(string: orgImageURL) {
                    self.loadImage(from: url)
                }
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
   

