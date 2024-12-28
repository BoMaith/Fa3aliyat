import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [Event] = []
    var filteredEvents: [Event] = []
    var interests: [String] = [] // This will hold the user's interests
    
    var userRole: UserRole = .regular  // Default role
    var currentUserEmail: String? // The email fetched from Firebase Auth
    var favoriteStates = [String: Bool]()

    
    struct Event {
        let id: String  // Unique ID for each event
        let title: String
        let date: String
        let category: String  // New field for the event category
        let imageURL: String // New field for the event's image URL
    }

    
    // Firebase Realtime Database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineUserRole()
        customizeSearchBarBackground()

        fetchEventsAndFavorites()  // Fetch events from Realtime Database
        
        // Initially show all events
        filteredEvents = events
        
        // Set up search bar delegate
        searchBar.delegate = self
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.events.removeAll()
        self.filteredEvents.removeAll()
        
        // Fetch events again when the page appears
        fetchEventsAndFavorites()
    }
    

    func fetchEventsAndFavorites() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Fetch events
        ref.child("events").observeSingleEvent(of: .value, with: { snapshot in
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                self.events = eventsData.compactMap { (id, data) in
                    guard let title = data["title"] as? String,
                          let date = data["date"] as? String,
                          let category = data["category"] as? String else { return nil }
                    
                    // Fetch image URL if it exists
                    guard let imageURL = data["imageURL"] as? String else {
                        return nil  // Return nil if imageURL is missing or invalid
                    }
                    return Event(id: id, title: title, date: date, category: category, imageURL: imageURL)

                }

                // Fetch user's favorites
                self.ref.child("users").child(userID).child("favorites").observeSingleEvent(of: .value, with: { snapshot in
                    if let favoriteIDs = snapshot.value as? [String: Bool] {
                        self.favoriteStates = favoriteIDs // Update the favoriteStates dictionary
                    }

                    // Fetch user's interests
                    self.ref.child("users").child(userID).child("interests").observeSingleEvent(of: .value, with: { snapshot in
                        if let interestsData = snapshot.value as? [String: Bool] {
                            self.interests = interestsData.keys.filter { interestsData[$0] == true }
                            print("Interests fetched: \(self.interests)")  // Debugging line
                        } else {
                            print("No interests found or incorrect path")  // Debugging line
                        }

                        // Reload the table view on the main thread
                        DispatchQueue.main.async {
                            self.filteredEvents = self.events
                            self.tableView.reloadData()
                        }
                    })
                })
            }
        }) { error in
            print("Error fetching events or favorites: \(error.localizedDescription)")
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? HomeTableViewCell else {
            fatalError("Unable to dequeue HomeTableViewCell")
        }

        let event = filteredEvents[indexPath.row]
        let isFavorite = favoriteStates[event.id] ?? false  // Default to false if not set
        
        // Check if the event's category is in the user's interests
        let isInterested = interests.contains(event.category)
        
        // Set the entire cell's background color to light yellow with alpha 0.5 if interested
        cell.backgroundColor = isInterested ? UIColor.blue.withAlphaComponent(0.25) : .customBackground
        
        // Set up the cell, now passing the non-optional imageURL
        let isStarButtonVisible = userRole == .regular
        cell.setupCell(name: event.title, date: event.date, imageURL: event.imageURL, isStarButtonVisible: isStarButtonVisible)
        
        //if let url = URL(string: event.imageURL) {
            // Make the image circular
            cell.imgEvent.layer.cornerRadius = cell.imgEvent.frame.size.width / 2
            cell.imgEvent.clipsToBounds = true
            cell.imgEvent.contentMode = .scaleAspectFill
        //} else {
            // Handle invalid URL if necessary (e.g., show a placeholder image)
            cell.imgEvent.image = UIImage(named: "placeholder")  // Replace with your placeholder image
        //}
        // Update the button state based on favoriteStates
        cell.starBtn.isSelected = isFavorite
        cell.starBtn.tintColor = isFavorite ? .systemBlue : .gray
        cell.starBtn.tag = indexPath.row

        // Remove the target if the star button is not visible
        if isStarButtonVisible {
            // Add target if the button is visible and the user is a regular user
            cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        } else {
            // Remove target if the button is not visible (admin/organizer)
            cell.starBtn.removeTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        }

        return cell
    }



    func reorderEventsBasedOnInterests(_ interests: [String]) {
        // Reorder events based on whether they are in the user's interests
        let interestedEvents = self.events.filter { interests.contains($0.id) }
        let otherEvents = self.events.filter { !interests.contains($0.id) }

        // Combine the two arrays, with the interested events first
        self.events = interestedEvents + otherEvents
        
        // Update the filtered events to reflect the new order
        self.filteredEvents = self.events
    }


    func updateFavoriteStateInFirebase(for event: Event, isFavorite: Bool) {
        let eventRef = ref.child("events").child(event.id)  // Use the event ID as the key
        eventRef.updateChildValues(["isFavorite": isFavorite]) { error, _ in
            if let error = error {
                print("Error updating favorite state: \(error)")
            } else {
                print("Favorite state updated successfully!")
            }
        }
    }

    
    // TableView DataSource and Delegate Methods remain the same
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? HomeTableViewCell else {
//            fatalError("Unable to dequeue HomeTableViewCell")
//        }
//        
//        let event = filteredEvents[indexPath.row]
//        let isFavorite = favoriteStates[event.id] ?? false  // Default to false if not set
//        
//        // Check if the event's category is in the user's interests
//        let isInterested = interests.contains(event.category)
//        
//        // Change the background color to yellow if the category matches an interest
//        cell.contentView.backgroundColor = isInterested ? .yellow : .white
//
//        // Set up the cell
//        let isStarButtonVisible = userRole == .regular
//        cell.setupCell(name: event.title, date: event.date, isStarButtonVisible: isStarButtonVisible)
//
//        // Update the button state based on favoriteStates
//        cell.starBtn.isSelected = isFavorite
//        cell.starBtn.tintColor = isFavorite ? .systemBlue : .gray
//        cell.starBtn.tag = indexPath.row
//
//        // Remove the target if the star button is not visible
//        if isStarButtonVisible {
//            // Add target if the button is visible and the user is a regular user
//            cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
//        } else {
//            // Remove target if the button is not visible (admin/organizer)
//            cell.starBtn.removeTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
//        }
//
//        return cell
//    }





     //Favorite Button Tapped Method (update Firebase when favorite is toggled)
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = filteredEvents[row] // Get the selected event

        // Determine the new favorite state (toggle)
        let isFavorite = !(favoriteStates[event.id] ?? false) // Default to `false` if no value exists
        favoriteStates[event.id] = isFavorite

        // Update the button's selected state and color
        sender.isSelected = isFavorite
        sender.tintColor = isFavorite ? .systemBlue : .gray

        // Update the user's favorites in Firebase
        updateFavoriteEvents(for: event.id, isFavorite: isFavorite)
    }



    func updateFavoriteEvents(for eventID: String, isFavorite: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let userFavoritesRef = ref.child("users").child(userID).child("favorites")
        
        if isFavorite {
            userFavoritesRef.updateChildValues([eventID: true]) // Add to favorites
        } else {
            userFavoritesRef.child(eventID).removeValue() // Remove from favorites
        }
    }


    
    // Search Bar Delegate Methods for filtering
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filterEvents(for searchText: String) {
        if searchText.isEmpty {
            filteredEvents = events  // Show all events if no search text
        } else {
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
    }
    
    func customizeSearchBarBackground() {
      
        // Set search bar's background color
        searchBar.barTintColor = .customBackground
        
        // Modify text field background if needed
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .customBackground // Set background color for the text field
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let eventID = sender as? String {
                if segue.identifier == "toAdminDetails", let destinationVC = segue.destination as? AdminEventViewController {
                    destinationVC.eventID = eventID
                } else if segue.identifier == "toOEDetails", let destinationVC = segue.destination as? OEDViewController {
                    destinationVC.eventID = eventID
                } else if segue.identifier == "toEventPage", let destinationVC = segue.destination as? EventViewController {
                    destinationVC.eventID = eventID
                }
            }
        }

        func determineUserRole() {
            guard let user = Auth.auth().currentUser, let email = user.email else { return }
            print(email)
            if email.contains("@fa3aliyat.organizer.bh") {
                userRole = .organizer
            } else if email.contains("@fa3aliyat.admin.bh") {
                userRole = .admin
            } else {
                userRole = .regular
            }
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedEvent = events[indexPath.row]
            let eventID = selectedEvent.id  // Get the event ID

            if (userRole == .admin){
                performSegue(withIdentifier: "toAdminDetails", sender: eventID)
            } else if (userRole == .organizer){
                performSegue(withIdentifier: "toOEDetails", sender: eventID)
            } else if (userRole == .regular){
                performSegue(withIdentifier: "toEventPage", sender: eventID)

            }
        }
        enum UserRole {
            case regular
            case organizer
            case admin
        }
}
