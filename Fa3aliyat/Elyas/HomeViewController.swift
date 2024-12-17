import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

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
    
    var filteredEvents: [(String, String, String)] = []
    var favoriteStates = [Bool](repeating: false, count: 9) // Count should match number of events

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredEvents = events // Initially show all events
        
        // Set up search bar delegate
        searchBar.delegate = self
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HomeTableViewCell
        
        let (eventName, eventDate, eventIcon) = filteredEvents[indexPath.row]
        cell.setupCell(photoName: eventIcon, name: eventName, date: eventDate, isFavorite: favoriteStates[indexPath.row])
        
        // Configure the favorite button
        cell.starBtn.isSelected = favoriteStates[indexPath.row]
        cell.starBtn.tag = indexPath.row
        cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle event selection
    }

    // MARK: - Favorite Button Tapped
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        favoriteStates[row].toggle() // Update favorite state
        sender.isSelected = favoriteStates[row] // Update button state
        
        // Reorder rows: move starred events to the top
        reorderRows()
    }

    private func reorderRows() {
        let combined = zip(filteredEvents, favoriteStates).sorted { $0.1 && !$1.1 }
        filteredEvents = combined.map { $0.0 }
        favoriteStates = combined.map { $0.1 }
        
        tableView.reloadData()
    }

    // MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents(for: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    private func filterEvents(for searchText: String) {
        if searchText.isEmpty {
            filteredEvents = events // Show all events if no search text
        } else {
            filteredEvents = events.filter { $0.0.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
    }
}
