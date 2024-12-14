import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
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

    var favoriteStates = [Bool](repeating: false, count: 6)

    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteStates = [Bool](repeating: false, count: events.count)

        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80 // Adjust based on your design
    }

    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Two sections: "Filters" and "Events"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Only 1 row for "Filters"
        } else {
            return events.count // All events for the second section
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
            let (eventName, eventDate, eventIcon) = events[indexPath.row]
            cell.setupCell(photoName: eventIcon, name: eventName, date: eventDate, isFavorite: favoriteStates[indexPath.row])

            // Configure the favorite button
            cell.starBtn.isSelected = favoriteStates[indexPath.row]
            cell.starBtn.tag = indexPath.row
            cell.starBtn.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

            return cell
        }
    }

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Handle event selection (navigate to details, for example)
        // print("Selected event: \(events[indexPath.row].0)")
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
        // Sort events based on favoriteStates
        let combined = zip(events, favoriteStates).sorted { $0.1 && !$1.1 }
        events = combined.map { $0.0 }
        favoriteStates = combined.map { $0.1 }

        // Reload the table view to reflect the new order
        tableView.reloadData()
    }
}
