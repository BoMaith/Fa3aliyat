import UIKit
import FirebaseDatabase

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pastEventsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var events: [Event] = []
    var filteredEvents: [Event] = []
    var pastEvents: [Event] = []

    struct Event {
        let id: String
        let title: String
        let date: String
    }

    var userID: String = "31QdzcuplceQvCN40rNdlOUJQGS2" // Hardcoded User ID for testing
    var userName: String = "John Doe" // Replace with actual user name

    // Firebase Realtime Database reference
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserJoinedEvents() // Fetch the user's joined events
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        pastEventsTableView.delegate = self
        pastEventsTableView.dataSource = self
        tableView.rowHeight = 80
        pastEventsTableView.rowHeight = 80
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
                    guard eventIDs.contains(key), let title = data["title"] as? String, let date = data["date"] as? String else { return nil }
                    return Event(id: key, title: title, date: date)
                }
                self.filteredEvents = self.events.filter { !self.isEventPast(date: $0.date) }
                self.pastEvents = self.events.filter { self.isEventPast(date: $0.date) }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.pastEventsTableView.reloadData()
                }
            }
        } withCancel: { error in
            print("Error fetching events: \(error.localizedDescription)")
        }
    }

    // Check if the event date is past
    func isEventPast(date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd - MMM dd"
        guard let eventDate = dateFormatter.date(from: date) else { return false }
        return eventDate < Date()
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return filteredEvents.count
        } else {
            return pastEvents.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HPendingTableViewCell
            let event = filteredEvents[indexPath.row]
            cell.setupCell2(name: event.title, date: event.date)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = pastEventsTableView.dequeueReusableCell(withIdentifier: "PastEventCell", for: indexPath) as! HDoneTableViewCell
            let event = pastEvents[indexPath.row]
            cell.setupCell(name: event.title, date: event.date)
            cell.RateBtn.tag = indexPath.row
            cell.RateBtn.addTarget(self, action: #selector(rateButtonTapped(_:)), for: .touchUpInside)

            // Fetch the rating if it exists
            ref.child("events").child(event.id).child("reviews").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    DispatchQueue.main.async {
                        cell.setRating(isRated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.setRating(isRated: false)
                    }
                }
            }

            return cell
        }
    }


    // Rate Button Action
    @objc func rateButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = pastEvents[row]

        // Check if the user has already rated this event
        ref.child("events").child(event.id).child("reviews").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let alert = UIAlertController(title: "Already Rated", message: "You have already rated this event.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Show rating popup
                let alert = UIAlertController(title: "Rate the Event", message: nil, preferredStyle: .alert)
                for i in 1...5 {
                    let action = UIAlertAction(title: "\(i) Stars", style: .default) { _ in
                        print("Rated \(i) stars for event: \(event.title)")
                        // Store rating in Firebase
                        self.storeRating(eventID: event.id, rating: i)
                    }
                    alert.addAction(action)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func storeRating(eventID: String, rating: Int) {
        let revID = UUID().uuidString // Generate a unique ID for the review
        let reviewData: [String: Any] = [
            "FullName": userName,
            "userID": userID,
            "rating": rating
        ]

        ref.child("events").child(eventID).child("reviews").child(revID).setValue(reviewData) { error, _ in
            if let error = error {
                print("Error storing rating: \(error.localizedDescription)")
            } else {
                print("Rating stored successfully!")
            }
        }
    }

    // Delete Button Action
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = filteredEvents[row]

        // Show confirmation alert
        let alert = UIAlertController(title: "Remove Event", message: "Are you sure you want to quit from this event? this event may not be refundable", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
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
            filteredEvents = events.filter { !isEventPast(date: $0.date) }
        } else {
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) && !isEventPast(date: $0.date) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
