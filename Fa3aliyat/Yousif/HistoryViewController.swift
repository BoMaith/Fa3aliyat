import UIKit
import FirebaseDatabase

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var events: [Event] = []
    var filteredEvents: [Event] = []

    struct Event {
        let id: String
        let title: String
        let date: String
    }

    var userID: String = "11X1KZw9AmXdJhsWg5Z8VvXXWwt2" // Hardcoded User ID for testing

    // Firebase Realtime Database reference
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserJoinedEvents() // Fetch the user's joined events
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
    }

    // Fetch user's joined events
    func fetchUserJoinedEvents() {
        ref.child("users").child(userID).child("JoinedEvents").observeSingleEvent(of: .value) { snapshot in
            if let joinedEvents = snapshot.value as? [[String: Any]] {
                let joinedEventIDs = joinedEvents.compactMap { $0["id"] as? String }
                self.fetchEvents(eventIDs: joinedEventIDs)
            } else {
                print("No joined events found.")
            }
        } withCancel: { error in
            print("Error fetching joined events: \(error.localizedDescription)")
        }
    }

    // Fetch events by their IDs
    func fetchEvents(eventIDs: [String]) {
        ref.child("events").observeSingleEvent(of: .value) { snapshot in
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                self.events = eventsData.compactMap { (key, data) in
                    guard eventIDs.contains(key),
                          let title = data["title"] as? String,
                          let date = data["date"] as? String else { return nil }
                    return Event(id: key, title: title, date: date)
                }

                print("Filtered Events: \(self.events)") // Debugging output
                self.filteredEvents = self.events
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } withCancel: { error in
            print("Error fetching events: \(error.localizedDescription)")
        }
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HPendingTableViewCell
        let event = filteredEvents[indexPath.row]
        cell.setupCell2(name: event.title, date: event.date)

        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

        return cell
    }

    // Delete Button Action
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = filteredEvents[row]

        // Show confirmation alert
        let alert = UIAlertController(title: "Remove Event", message: "Are you sure you want to remove this event?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            // Remove the event from the user's JoinedEvents list
            self.ref.child("users").child(self.userID).child("JoinedEvents").observeSingleEvent(of: .value) { snapshot in
                if var joinedEvents = snapshot.value as? [[String: Any]] {
                    joinedEvents.removeAll { joinedEvent in
                        guard let id = joinedEvent["id"] as? String else { return false }
                        return id == event.id
                    }
                    self.ref.child("users").child(self.userID).child("JoinedEvents").setValue(joinedEvents)
                }
            }

            // Remove the user from the event's participants
            self.ref.child("events").child(event.id).child("participants").observeSingleEvent(of: .value) { snapshot in
                if var participants = snapshot.value as? [[String: Any]] {
                    participants.removeAll { participant in
                        guard let id = participant["id"] as? String else { return false }
                        return id == self.userID
                    }
                    self.ref.child("events").child(event.id).child("participants").setValue(participants)
                }
            }

            // Remove the event from the local array
            self.filteredEvents.remove(at: row)
            self.events.removeAll { $0.id == event.id }

            // Delete the row from the table view
            self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        })
        present(alert, animated: true, completion: nil)
    }

    // Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEvents = events
        } else {
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
