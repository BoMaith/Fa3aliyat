import UIKit
import FirebaseAuth
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
    var userRole: UserRole = .regular  // Default role

    
    // This property will hold the filters array passed from FiltersTableViewController
    var filtersArray: [Any?] = [nil, nil, nil, nil, nil, nil]  // Default value

    func didApplyFilters(_ filters: [Any?]) {
            filtersArray = filters
            print("Received filters: \(filtersArray)")
            applyFilters() // Call this to update the displayed events
        }
    
    func normalizeFilterTimeTo12HourFormat(_ timeString: String) -> String? {
        let timeFormatter12Hour = DateFormatter()
        timeFormatter12Hour.dateFormat = "h:mm a" // 12-hour format with AM/PM

        let timeFormatter24Hour = DateFormatter()
        timeFormatter24Hour.dateFormat = "HH:mm" // 24-hour format

        if let timeDate = timeFormatter24Hour.date(from: timeString) {
            // Convert from 24-hour format to 12-hour format
            return timeFormatter12Hour.string(from: timeDate)
        }

        if let timeDate = timeFormatter12Hour.date(from: timeString) {
            return timeFormatter12Hour.string(from: timeDate)
        }

        return nil
    }
    func normalizeEventTimeTo12HourFormat(_ eventTime: String) -> String? {
        let timeFormatter12Hour = DateFormatter()
        timeFormatter12Hour.dateFormat = "h:mm a" // 12-hour format with AM/PM
        
        let timeFormatter24Hour = DateFormatter()
        timeFormatter24Hour.dateFormat = "HH:mm" // 24-hour format

        if let eventDate = timeFormatter24Hour.date(from: eventTime) {
            // Convert 24-hour format to 12-hour format
            return timeFormatter12Hour.string(from: eventDate)
        }
        
        // If already in 12-hour format, return the time as is
        if let eventDate = timeFormatter12Hour.date(from: eventTime) {
            return timeFormatter12Hour.string(from: eventDate)
        }
        
        return nil // Return nil if format is unrecognized
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
            dateFormatter.dateFormat = "dd/MM/yyyy"  // Target format for both dateFilter, startDate, and endDate

            filteredEvents = filteredEvents.filter { event in
                // Only check if startDate and endDate are present
                if let startDate = event.startDate, let endDate = event.endDate {
                    if let filterDate = dateFormatter.date(from: dateFilter),
                       let startDateDate = dateFormatter.date(from: startDate),
                       let endDateDate = dateFormatter.date(from: endDate) {
                        // Check if the filter date is within the range of startDate and endDate
                        return (filterDate >= startDateDate) && (filterDate <= endDateDate)
                    }
                }
                
                // If event doesn't meet date criteria, return false
                return false
            }
        }




        // Filter by time
        if let timeFilter = filtersArray[2] as? String, !timeFilter.isEmpty {
               print("Filtering by time: \(timeFilter)")

               // Normalize the filter time to 12-hour format
               if let normalizedTimeFilter = normalizeFilterTimeTo12HourFormat(timeFilter) {
                   // Filter events based on the normalized time
                   filteredEvents = filteredEvents.filter { event in
                       if let eventTime = event.time, !eventTime.isEmpty {
                           if let normalizedEventTime = normalizeEventTimeTo12HourFormat(eventTime) {
                               return normalizedEventTime == normalizedTimeFilter
                           } else {
                               print("Invalid time format for event: \(event.title), Time: \(event.time ?? "N/A")")
                               return false
                           }
                       } else {
                           print("Event has no time specified: \(event.title)")
                           return false
                       }
                   }
               }
           }



        print("After date filter: \(filteredEvents.count)") // Check count after filter

        // Filter by price
        if let priceFilter = filtersArray[3] as? String, !priceFilter.isEmpty {
            print("Filtering by price: \(priceFilter)")
            filteredEvents = filteredEvents.filter { event in
                guard let priceValue = event.price else { return false }

                // Check if the price is 0 (treated as free)
                if priceValue == 0 {
                    return priceFilter.lowercased() == "free"
                } else {
                    // Handle price ranges for non-free events
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
            }
        }


        print("After price filter: \(filteredEvents.count)") // Check count after filter

        // Filter by location
        if let locationFilter = filtersArray[4] as? String, !locationFilter.isEmpty {
            print("Filtering by location: \(locationFilter)")
            let trimmedLocationFilter = locationFilter.trimmingCharacters(in: .whitespacesAndNewlines)
            
            filteredEvents = filteredEvents.filter { event in
                // Compare location (if exists) and ignore case differences
                if let eventLocation = event.location {
                    return eventLocation.lowercased() == trimmedLocationFilter.lowercased()
                }
                return false  // Return false if the event has no location
            }
        }

        print("After location filter: \(filteredEvents.count)") // Check count after filter

        // Filter by age
        
        if let ageFilter = filtersArray[5] as? String, !ageFilter.isEmpty {
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
        determineUserRole()
        customizeSearchBarBackground()
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
    
    // Fetch events from Firebase
    func fetchEvents() {
        ref.child("events").observeSingleEvent(of: .value, with: { snapshot in
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                self.events = eventsData.compactMap { (id, data) -> Event? in
                    // Guard for mandatory fields, including date
                    guard let title = data["title"] as? String,
                          let date = data["date"] as? String else {
                        return nil
                    }
                    
                    // Assign startDate and endDate as optional
                    let startDate = data["startDate"] as? String
                    let endDate = data["endDate"] as? String
                    let time = data["time"] as? String  // Optional time
                    let price = data["price"] as? Double  // Price is optional
                    guard let imageURL = data["imageURL"] as? String else {
                        return nil  // Return nil if imageURL is missing or invalid
                    }
                    
                    // Return event object with date, startDate, and endDate
                    return Event(
                        id: id,
                        title: title,
                        date: date,            // Non-optional date
                        startDate: startDate,  // Optional startDate
                        endDate: endDate,    // Optional endDate
                        time: time,
                        //isFavorite: isFavorite,
                        price: price,
                        location: data["location"] as? String,
                        age: data["age"] as? Int,
                        category: data["category"] as? String,
                        imageURL: imageURL
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
            // Event Row
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! SearchTableViewCell
            let event = filteredEvents[indexPath.row]
            
           // if let url = URL(string: event.imageURL) {
                // Make the image circular
                cell.imgEvent.layer.cornerRadius = cell.imgEvent.frame.size.width / 2
                cell.imgEvent.clipsToBounds = true
                cell.imgEvent.contentMode = .scaleAspectFill
            //} else {
                // Handle invalid URL if necessary (e.g., show a placeholder image)
                cell.imgEvent.image = UIImage(named: "placeholder")  // Replace with your placeholder image
           // }
            
            cell.setupCell(name: event.title, date: event.date, imageURL: event.imageURL)

            return cell
        }
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

    // MARK: - Event Model
    struct Event {
        let id: String  // Unique ID for each event
        let title: String
        let date: String
        let startDate: String? // Optional: The start date of the event (can be nil)
        let endDate: String?
        let time: String?
        //var isFavorite: Bool
        let price: Double?  // Optional to handle cases where price might be missing
        let location: String?
        let age: Int?    // Optional to handle cases where age might be missing
        let category: String? // Add the category property
        let imageURL: String // New field for the event's image URL
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
            if let filterVC = segue.destination as? FiltersTableViewController {
                filterVC.delegate = self
            }
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
        // Check if the selected row is the filter cell in section 0, row 0
        if indexPath.section == 0 && indexPath.row == 0 {
            // Perform segue to the filter page only
            performSegue(withIdentifier: "toFilterPage", sender: nil)
        } else {
            // Proceed with the original behavior for other rows
            let selectedEvent = events[indexPath.row]
            let eventID = selectedEvent.id  // Get the event ID
            
            if userRole == .admin {
                performSegue(withIdentifier: "toAdminDetails", sender: eventID)
            } else if userRole == .organizer {
                performSegue(withIdentifier: "toOEDetails", sender: eventID)
            } else if userRole == .regular {
                performSegue(withIdentifier: "toEventPage", sender: eventID)
            }
        }
    }

    
    enum UserRole {
        case regular
        case organizer
        case admin
    }
}
    

