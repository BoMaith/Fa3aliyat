import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events: [(String, String, String)] = [
        ("Car Show", "Nov 11 - Nov 13", "Cars"),
        ("Quran Tajweed", "Nov 10 - Nov 11", "Cars"),
        ("Football Tournament", "Dec 1 - Dec 2", "Cars"),
        ("Food Truck Event", "Nov 3", "Cars"),
        ("Traditional Food Event", "Nov 3 - Nov 5", "Cars"),
        ("Tennis Tournament", "Nov 14 - Nov 19", "Cars"),
        ("Food Truck Event", "Nov 3", "Cars"),
        ("Traditional Food Event", "Nov 3 - Nov 5", "Cars"),
        ("Tennis Tournament", "Nov 14 - Nov 19", "Cars")
    ]
    
    var favoriteStates = [Bool](repeating: false, count: 9)
    var filteredEvents: [(String, String, String)] = []
    var filteredFavoriteStates: [Bool] = []

    
    
    
    
    
    // This property will hold the filters array passed from FiltersTableViewController
       var filtersArray: [Any?] = [nil, nil, nil, nil, nil]  // Default value

    // Example method to apply filters to your search logic
        func applyFilters() {
            // Example method to apply filters to your search logic
                   print("Applying filters...")
            // Logic to filter results based on the selected filters in filtersArray
            // For example:
            if let category = filtersArray[0] as? String {
                print("Applying category filter: \(category)")
            }
            if let dateAndTime = filtersArray[1] as? String {
                print("Applying date filter: \(dateAndTime)")
            }
            if let price = filtersArray[2] as? String {
                print("Applying price filter: \(price)")
            }
            if let location = filtersArray[3] as? String {
                print("Applying location filter: \(location)")
            }
            if let age = filtersArray[4] as? String {
                print("Applying age filter: \(age)")
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example: Handle the received filters if needed
        print("Received filters: \(filtersArray)")
        
        // You can now use the filtersArray to filter the search results
        applyFilters()
        
        
        
        
        
        
        
        
        
        
        
        filteredEvents = events
        filteredFavoriteStates = favoriteStates
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
        
        // Set the search bar delegate
        searchBar.delegate = self
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
            // "Events" Rows
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! SearchTableViewCell

            // Event details
            let (eventName, eventDate, eventIcon) = filteredEvents[indexPath.row]
            cell.setupCell(photoName: eventIcon, name: eventName, date: eventDate, isFavorite: filteredFavoriteStates[indexPath.row])

            // Configure the favorite button
            cell.starBtn.isSelected = filteredFavoriteStates[indexPath.row]
            cell.starBtn.tag = indexPath.row
            cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

            return cell
        }
    }

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Handle event selection (navigate to details, for example)
        // print("Selected event: \(filteredEvents[indexPath.row].0)")
    }

    // MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents(for: searchText) // Call the filter function every time the search text changes
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss keyboard when search button is clicked
    }

    // MARK: - Filter Events based on Search Text
    private func filterEvents(for searchText: String) {
        if searchText.isEmpty {
            // If no search text, show all events
            filteredEvents = events
            filteredFavoriteStates = favoriteStates
            
            // Reorder the events so that the favorites are on top
            reorderRows()
        } else {
            // Filter events based on the event name
            filteredEvents = events.filter { $0.0.lowercased().contains(searchText.lowercased()) }
            
            // Map the favorite states to the filtered events using the event name as a key
            filteredFavoriteStates = filteredEvents.map { event in
                if let index = events.firstIndex(where: { $0.0 == event.0 }) {
                    return favoriteStates[index] // Ensure the original favorite state is preserved
                }
                return false // Default to false if event not found
            }
        }
        tableView.reloadData() // Reload the table view with filtered events
    }

    // MARK: - Favorite Button Tapped
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        filteredFavoriteStates[row].toggle() // Update favorite state for filtered events
        sender.isSelected = filteredFavoriteStates[row] // Update button state

        // Save the new favorite state back to the original `favoriteStates` array
        let originalIndex = events.firstIndex(where: { $0.0 == filteredEvents[row].0 })
        if let index = originalIndex {
            favoriteStates[index] = filteredFavoriteStates[row] // Update the original favorite state
        }

        // Reorder rows: move starred events to the top
        reorderRows()
    }

    private func reorderRows() {
        // Sort events based on favoriteStates
        let combined = zip(filteredEvents, filteredFavoriteStates).sorted { $0.1 && !$1.1 }
        filteredEvents = combined.map { $0.0 }
        filteredFavoriteStates = combined.map { $0.1 }

        // Reload the table view to reflect the new order
        tableView.reloadData()
    }
}
