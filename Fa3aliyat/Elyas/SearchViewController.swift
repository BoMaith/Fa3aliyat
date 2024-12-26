import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Firebase Realtime Database reference
    var ref: DatabaseReference!

    // Events array populated from Firebase
    var events: [Event] = []
    var filteredEvents: [Event] = []
    var favoriteStates = [Bool](repeating: false, count: 9)
    var filteredFavoriteStates: [Bool] = []

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filterVC = segue.destination as? FiltersTableViewController {
            filterVC.delegate = self
        }
    }
    
    
    // This property will hold the filters array passed from FiltersTableViewController
       var filtersArray: [Any?] = [nil, nil, nil, nil, nil]  // Default value

    func didApplyFilters(_ filters: [Any?]) {
            filtersArray = filters
            print("Received filters: \(filtersArray)")
            applyFilters() // Call this to update the displayed events
        }
    
    // Example method to apply filters to your search logic
    func applyFilters() {
        // Start with all events
        filteredEvents = events
        print("Initial events count: \(filteredEvents.count)") // Add this line for debugging
        
        // Filter by category
        if let categoryFilter = filtersArray[0] as? String, !categoryFilter.isEmpty {
            print("Filtering by category: \(categoryFilter)")
            filteredEvents = filteredEvents.filter { event in
                event.category?.lowercased() == categoryFilter.lowercased()
            }
        }

        print("After category filter: \(filteredEvents.count)") // Check count after filter

        // Filter by date
        if let dateFilter = filtersArray[1] as? String, !dateFilter.isEmpty {
            print("Filtering by date: \(dateFilter)")
            
            // DateFormatter to ensure the comparison is in "dd/MM/yyyy" format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"  // Target format for both dateFilter and event.date
            
            filteredEvents = filteredEvents.filter { event in
                // Ensure the event date is in a comparable format
                let eventDateString = event.date  // Direct access if event.date is non-optional
                if let eventDate = dateFormatter.date(from: eventDateString) {
                    // Format the event date to "dd/MM/yyyy" to exclude time
                    let formattedEventDate = dateFormatter.string(from: eventDate)
                    return formattedEventDate == dateFilter
                } else {
                    print("Invalid date format for event: \(event.title), Date: \(event.date)")
                    return false
                }
            }
        }


        print("After date filter: \(filteredEvents.count)") // Check count after filter

        // Filter by price
        if let priceFilter = filtersArray[2] as? String, !priceFilter.isEmpty {
            print("Filtering by price: \(priceFilter)")
            filteredEvents = filteredEvents.filter { event in
                guard let priceString = event.price else { return false }
                
                if priceString.lowercased() == "free" {
                    return priceFilter.lowercased() == "free"
                } else if let priceValue = Double(priceString) {
                    switch priceFilter {
                    case "0.1 - 4.9 BD":
                        return priceValue >= 0.1 && priceValue <= 4.9
                    case "5 - 9.9 BD":
                        return priceValue >= 5 && priceValue <= 9.9
                    case "10 - 19.9 BD":
                        return priceValue >= 10 && priceValue <= 19.9
                    case "20+ BD":
                        return priceValue >= 20
                    default:
                        return false
                    }
                }
                return false
            }
        }

        print("After price filter: \(filteredEvents.count)") // Check count after filter

        // Filter by location
        if let locationFilter = filtersArray[3] as? String, !locationFilter.isEmpty {
            print("Filtering by location: \(locationFilter)")
            filteredEvents = filteredEvents.filter { event in
                event.location?.lowercased() == locationFilter.lowercased()
            }
        }

        print("After location filter: \(filteredEvents.count)") // Check count after filter

        // Filter by age
        
        if let ageFilter = filtersArray[4] as? String, !ageFilter.isEmpty {
            print("Filtering by age: \(ageFilter)")
            
            filteredEvents = filteredEvents.filter { event in
                // Debugging the event details
                print("Event: \(event.title), Age: \(event.age ?? -1), Category: \(event.category ?? "N/A")")
                
                guard let ageValue = event.age else {
                    print("No valid age found for event: \(event.title)")
                    return false
                }

                print("Event title: \(event.title), Event age: \(ageValue), Applying filter: \(ageFilter)")

                if ageFilter == "Family-Friendly" {
                    return ageValue < 12
                }

                if ageFilter == "12 - 18 years" {
                    return ageValue > 11 && ageValue < 19
                }

                if ageFilter == "18+ years" {
                    return ageValue > 18
                }

                return false
            }
        }

        print("After age filter: \(filteredEvents.count) events remaining")
        tableView.reloadData()
    }



    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example: Handle the received filters if needed
        print("Received filters: \(filtersArray)")
        
        // You can now use the filtersArray to filter the search results
        applyFilters()
        
        
        // Initialize Firebase database reference
        ref = Database.database().reference()
                
        // Fetch events from Firebase Realtime Database
        fetchEvents()
        
        //filteredEvents = events
        filteredFavoriteStates = favoriteStates
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
        
        // Set the search bar delegate
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.events.removeAll()
        self.filteredEvents.removeAll()
        
        // Fetch events again when the page appears
        fetchEvents()
    }
    
    // Fetch events from Firebase using the same approach as in the Home page
    func fetchEvents() {
        
        ref.child("events").observeSingleEvent(of: .value, with: { snapshot in
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                self.events = eventsData.compactMap { (id, data) -> Event? in
                    guard
                        let title = data["title"] as? String,
                        let date = data["date"] as? String,
                        let isFavorite = data["isFavorite"] as? Bool
                    else {
                        return nil
                    }
                    
                    // Ensure age is parsed correctly
                       let age = data["age"] as? Int ?? -1  // Default to -1 if not found or cannot be casted
                    
                    // Return event object
                    return Event(
                        id: id,
                        title: title,
                        date: date,
                        isFavorite: isFavorite,
                        price: data["price"] as? String,
                        location: data["location"] as? String,
                        age: data["age"] as? Int,
                        category: data["category"] as? String
                    )
                }
                
                // Initially set filteredEvents to all fetched events
                self.filteredEvents = self.events
                
                DispatchQueue.main.async {
                    // Apply filters if any are set
                    self.applyFilters()
                    // Reload table view
                    self.tableView.reloadData()
                }
            }
        }) { error in
            print("Error fetching events: \(error.localizedDescription)")
        }
    }


    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Two sections: "Filters" and "Events"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Only 1 row for "Filters"
        } else {
            return filteredEvents.count // All filtered events for the second section
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Filters"
        } else {
            return "Events"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // "Filters" Row
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! SearchTableViewCell
            let filter = ("Filters_img", "Filters")
            cell.setupCellFilter(photoName: filter.0, name: filter.1)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! SearchTableViewCell
            let event = filteredEvents[indexPath.row]
            
            cell.setupCell(name: event.title, date: event.date, isFavorite: event.isFavorite)
            cell.starBtn.isSelected = event.isFavorite
            cell.starBtn.tag = indexPath.row
            // Change the color based on isFavorite value
            if event.isFavorite {
                cell.starBtn.tintColor = .systemBlue // Set color when favorite
            } else {
                cell.starBtn.tintColor = .gray // Set color when not favorite
            }
            // Add target for button tap action
            cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

            return cell
        }
    }
    
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
            sender.tintColor = .systemBlue // Button color when selected (favorite)
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

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Handle event selection (navigate to details, for example)
        // print("Selected event: \(filteredEvents[indexPath.row].0)")
    }

 //    MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents(for: searchText) // Call the filter function every time the search text changes
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss keyboard when search button is clicked
    }

    // MARK: - Filter Events based on Search Text
    private func filterEvents(for searchText: String) {
        if searchText.isEmpty {
            filteredEvents = events  // Show all events if no search text
        } else {
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
    }

    private func reorderRows() {
        // Sort events based on favoriteStates
        let combined = zip(filteredEvents, filteredFavoriteStates).sorted { $0.1 && !$1.1 }
        filteredEvents = combined.map { $0.0 }
        filteredFavoriteStates = combined.map { $0.1 }

        // Reload the table view to reflect the new order
        tableView.reloadData()
    }
    
    // MARK: - Event Model
    struct Event {
        let id: String  // Unique ID for each event
        let title: String
        let date: String
        var isFavorite: Bool
        let price: String?  // Optional to handle cases where price might be missing
        let location: String?
        let age: Int?    // Optional to handle cases where age might be missing
        let category: String? // Add the category property
        }
}
    

