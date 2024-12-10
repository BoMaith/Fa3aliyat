import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    let events: [(String, String, String)] = [
        ("Car Show", "Nov 11 - Nov 13", "Cars"),
            ("Quran Tajweed", "Nov 10 - Nov 11", "Cars"),
            ("Football Tournament", "Dec 1 - Dec 2", "Cars"),
            ("Food Truck Event", "Nov 3", "Cars"),
            ("Traditional Food Event", "Nov 3 - Nov 5", "Cars"),
            ("Tennis Tournament", "Nov 14 - Nov 19", "Cars")
    ]
 
    var favoriteStates = [Bool](repeating: false, count: 6)

        override func viewDidLoad() {
            super.viewDidLoad()

            // Set up table view
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 80 // Adjust based on your design
        }

        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return events.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HomeTableViewCell

            // Event details
            let (eventName, eventDate, eventIcon) = events[indexPath.row]
            cell.setupCell(photoName: eventIcon, name: eventName, date: eventDate)
            
            // Configure the favorite button
//            cell.favoriteButton.isSelected = favoriteStates[indexPath.row]
//            cell.favoriteButton.tag = indexPath.row
//            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

            return cell
        }

        // MARK: - TableView Delegate Methods
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // Handle event selection (navigate to details, for example)
//            print("Selected event: \(events[indexPath.row].0)")
        }

        // MARK: - Favorite Button Tapped
        @objc func favoriteButtonTapped(_ sender: UIButton) {
            let row = sender.tag
            favoriteStates[row].toggle()
            sender.isSelected = favoriteStates[row]

            // You can save the favorite state in UserDefaults or a database if needed
            print("Favorite state for row \(row): \(favoriteStates[row])")
        }
    }

