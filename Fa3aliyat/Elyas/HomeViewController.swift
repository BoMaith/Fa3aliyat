import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [Event] = []
    var filteredEvents: [Event] = []
    
    
    
    struct Event {
        let id: String  // Unique ID for each event
        let title: String
        let date: String
        var isFavorite: Bool
    }
    
    var favoriteStates = [Bool]()
    
    // Firebase Realtime Database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvents()  // Fetch events from Realtime Database
        
        // Initially show all events
        filteredEvents = events
        
        // Set up search bar delegate
        searchBar.delegate = self
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
    }
    
    // Fetch events from Firebase Realtime Database
//    func fetchEvents() {
//        ref.child("events").observeSingleEvent(of: .value, with: { snapshot in
//            // Check if snapshot has data
//            if let eventsData = snapshot.value as? [String: [String: Any]] {
//                self.events = eventsData.compactMap { (key, data) in
//                    guard
//                        let title = data["title"] as? String,
//                        let date = data["date"] as? String,
//                        let isFavorite = data["isFavorite"] as? Bool
//                    else { return nil }
//
//                    return Event(title: title, date: date, isFavorite: isFavorite)
//                }
//                
//                print("Fetched Events: \(self.events)") // Log events to check if they're fetched properly
//                
//                self.filteredEvents = self.events
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }) { error in
//            print("Error fetching events: \(error.localizedDescription)")
//        }
//    }
    
    func fetchEvents() {
        ref.child("events").observeSingleEvent(of: .value, with: { snapshot in
            // Check if snapshot has data
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                self.events = eventsData.compactMap { (id, data) in
                    guard
                        let title = data["title"] as? String,
                        let date = data["date"] as? String,
                        let isFavorite = data["isFavorite"] as? Bool
                    else { return nil }
                    
                    return Event(id: id, title: title, date: date, isFavorite: isFavorite)
                }
                
                print("Fetched Events: \(self.events)") // Log events to check if they're fetched properly
                
                self.filteredEvents = self.events
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { error in
            print("Error fetching events: \(error.localizedDescription)")
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
        
        cell.setupCell(name: event.title, date: event.date, isFavorite: event.isFavorite)
        
        // Set the button's selected state based on the event's isFavorite value
        cell.starBtn.isSelected = event.isFavorite
        cell.starBtn.tag = indexPath.row
        // Change the color based on isFavorite value
        if event.isFavorite {
            cell.starBtn.tintColor = .blue // Set color when favorite
        } else {
            cell.starBtn.tintColor = .gray // Set color when not favorite
        }
        
        // Add target for button tap action
        cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
         
        return cell
    }

    // Favorite Button Tapped Method (update Firebase when favorite is toggled)
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
//            sender.tintColor = .blue // Button color when selected (favorite)
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


    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        
        // Access the event object from filteredEvents
        var event = filteredEvents[row]
        
        // Toggle the favorite state
        event.isFavorite.toggle()

        // Update the button's selected state
        sender.isSelected = event.isFavorite
        
        // Change the button's color based on the favorite state
        if event.isFavorite {
            sender.tintColor = .blue // Button color when selected (favorite)
        } else {
            sender.tintColor = .gray // Button color when not selected (not favorite)
        }
        
        // Update the event in the filteredEvents array
        filteredEvents[row] = event
        
        // Update Firebase with the new favorite state
        updateFavoriteStateInFirebase(for: event, isFavorite: event.isFavorite)
        
        // Reload the row to reflect the changes
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }




    private func reorderRows() {
        // Sort filteredEvents to put favorites at the top (or bottom depending on your preference)
        filteredEvents.sort { $0.isFavorite && !$1.isFavorite }
        
        // Reload the table view to reflect the changes
        tableView.reloadData()
    }
    
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
}
