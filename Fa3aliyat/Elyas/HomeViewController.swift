import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [Event] = []
    var filteredEvents: [Event] = []
    
    
    var userRole: UserRole = .regular  // Default role
    var currentUserEmail: String? // The email fetched from Firebase Auth
    var favoriteStates = [String: Bool]()

    
    struct Event {
        let id: String  // Unique ID for each event
        let title: String
        let date: String
    }

    
    // Firebase Realtime Database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineUserRole()
        
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
                    guard
                        let title = data["title"] as? String,
                        let date = data["date"] as? String
                    else { return nil }
                    
                    return Event(id: id, title: title, date: date)
                }
                
                // Fetch user's favorites
                self.ref.child("users").child(userID).child("favorites").observeSingleEvent(of: .value, with: { snapshot in
                    if let favoriteIDs = snapshot.value as? [String: Bool] {
                        self.favoriteStates = favoriteIDs // Update the favoriteStates dictionary
                    }
                    
                    // Reload the table view on the main thread
                    DispatchQueue.main.async {
                        self.filteredEvents = self.events
                        self.tableView.reloadData()
                    }
                })
            }
        }) { error in
            print("Error fetching events or favorites: \(error.localizedDescription)")
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HomeTableViewCell
        let event = filteredEvents[indexPath.row]
        
        cell.setupCell(name: event.title, date: event.date)
        
        // Set the button state based on favoriteStates
        let isFavorite = favoriteStates[event.id] ?? false
        cell.starBtn.isSelected = isFavorite
        cell.starBtn.tintColor = isFavorite ? .systemBlue : .gray
        cell.starBtn.tag = indexPath.row
        
        // Add target for button tap action
        cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }


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




//    @objc func favoriteButtonTapped(_ sender: UIButton) {
//        let row = sender.tag
//        
//        // Access the event object from filteredEvents
//        var event = filteredEvents[row]
//        
//        // Toggle the favorite state
//        event.isFavorite.toggle()
//
//        // Update the button's selected state
//        sender.isSelected = event.isFavorite
//        
//        // Change the button's color based on the favorite state
//        if event.isFavorite {
//            sender.tintColor = .systemBlue // Button color when selected (favorite)
//        } else {
//            sender.tintColor = .gray // Button color when not selected (not favorite)
//        }
//        
//        // Update the event in the filteredEvents array
//        filteredEvents[row] = event
//        
//        // Update Firebase with the new favorite state
//        updateFavoriteStateInFirebase(for: event, isFavorite: event.isFavorite)
//        
//        // Reload the row to reflect the changes
//        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//    }




//    private func reorderRows() {
//        // Sort filteredEvents to put favorites at the top (or bottom depending on your preference)
//        filteredEvents.sort { $0.isFavorite && !$1.isFavorite }
//        
//        // Reload the table view to reflect the changes
//        tableView.reloadData()
//    }
    
    // Update favorite state in Firebase Realtime Database
//    func updateFavoriteStateInFirebase(for event: Event, isFavorite: Bool) {
//        let eventRef = ref.child("events").child(event.title)  // Use the event title as the key
//        eventRef.updateChildValues(["isFavorite": isFavorite]) { error, _ in
//            if let error = error {
//                print("Error updating favorite state: \(error)")
//            } else {
//                print("Favorite state updated successfully!")
//            }
//        }
//    }
    
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
