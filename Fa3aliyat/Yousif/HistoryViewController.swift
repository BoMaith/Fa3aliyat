import UIKit
import FirebaseDatabase
import FirebaseAuth

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
        let startDate: String
        let endDate: String
    }

    // Get userID from the logged-in user
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var userName: String? {
        return Auth.auth().currentUser?.displayName
    }

    // Firebase Realtime Database reference
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userID = userID {
            fetchUserJoinedEvents(userID: userID) // Fetch the user's joined events
        } else {
            print("Error: No user is logged in.")
        }
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        pastEventsTableView.delegate = self
        pastEventsTableView.dataSource = self
        tableView.rowHeight = 80
        pastEventsTableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated) 
        refreshData()
    }
    
    func refreshData() { guard let userID = userID
        else { print("Error: No user is logged in.")
        return }
        fetchUserJoinedEvents(userID: userID) }
    
    // Fetch user's joined events
    func fetchUserJoinedEvents(userID: String) {
        ref.child("users").child(userID).child("JoinedEvents").observeSingleEvent(of: .value) { snapshot in
            if let joinedEvents = snapshot.value as? [[String: Any]] {
                let joinedEventIDs = joinedEvents.compactMap { $0["id"] as? String }
                print("Joined Event IDs: \(joinedEventIDs)")
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
                self.events = eventsData.compactMap { (key, data) -> Event? in
                    guard eventIDs.contains(key),
                          let title = data["title"] as? String,
                          let startDate = data["startDate"] as? String,
                          let endDate = data["endDate"] as? String else {
                              return nil
                          }
                    return Event(id: key, title: title, startDate: startDate, endDate: endDate)
                }
                // Print events for debugging
                self.events.forEach { event in
                    print("Event: \(event.title), StartDate: \(event.startDate)")
                }
                self.filteredEvents = self.events.filter { self.isEventPending(startDate: $0.startDate) }
                self.pastEvents = self.events.filter { !self.isEventPending(startDate: $0.startDate) }
                // Print filtered events for debugging
                print("Pending Events: \(self.filteredEvents.map { $0.title })")
                print("Past Events: \(self.pastEvents.map { $0.title })")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.pastEventsTableView.reloadData()
                }
            }
        }
    }

    // Check if the event startDate is pending
    func isEventPending(startDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Ensure this matches your date format
        guard let eventDate = dateFormatter.date(from: startDate) else {
            print("Invalid date format for event startDate: \(startDate)")
            return false
        }
        let currentDate = Date()
        return eventDate >= currentDate
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
            cell.setupCell2(name: event.title, date: event.startDate)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = pastEventsTableView.dequeueReusableCell(withIdentifier: "PastEventCell", for: indexPath) as! HDoneTableViewCell
            let event = pastEvents[indexPath.row]
            cell.setupCell(name: event.title, date: event.startDate)
            cell.RateBtn.tag = indexPath.row
            cell.RateBtn.addTarget(self, action: #selector(rateButtonTapped(_:)), for: .touchUpInside)

            // Fetch the rating if it exists
            ref.child("events").child(event.id).child("reviews").queryOrdered(byChild: "userID").queryEqual(toValue: userID!).observeSingleEvent(of: .value) { snapshot in
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

    // TableView Delegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let selectedEvent = filteredEvents[indexPath.row]
            performSegue(withIdentifier: "toEventPage", sender: selectedEvent)
        }
    }

    
    
    
    
    
    
    
    

    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventPage",
           let eventPageVC = segue.destination as? EventViewController,
           let selectedEvent = sender as? Event {
            eventPageVC.eventID = selectedEvent.id
        }
    }

    // Handle the delete button tap
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = filteredEvents[row]

        // Show confirmation alert
        let alert = UIAlertController(title: "Remove Event", message: "Are you sure you want to quit from this event? This event may not be refundable.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            guard let userID = self.userID else {
                print("Error: No user is logged in.")
                return
            }

            // Remove the event from the user's JoinedEvents list
            self.ref.child("users").child(userID).child("JoinedEvents").observeSingleEvent(of: .value) { snapshot in
                if var joinedEvents = snapshot.value as? [[String: Any]] {
                    joinedEvents.removeAll { joinedEvent in
                        guard let id = joinedEvent["id"] as? String else { return false }
                        return id == event.id
                    }
                    self.ref.child("users").child(userID).child("JoinedEvents").setValue(joinedEvents)
                }
            }

            // Remove the user from the event's participants
            self.ref.child("events").child(event.id).child("participants").observeSingleEvent(of: .value) { snapshot in
                if var participants = snapshot.value as? [String: Any] {
                    participants.removeValue(forKey: userID)
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
    
    @objc func rateButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let event = pastEvents[row]

        // Show the rating interface or handle the rating action
        let alert = UIAlertController(title: "Rate Event", message: "Provide your rating for the event.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter your rating (1-5)"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let ratingText = alert.textFields?.first?.text, let rating = Int(ratingText), rating >= 1 && rating <= 5 {
                self.submitRating(for: event, rating: rating)
            } else {
                // Show an error message if the rating is invalid
                let errorAlert = UIAlertController(title: "Invalid Rating", message: "Please enter a valid rating between 1 and 5.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
        present(alert, animated: true, completion: nil)
    }

    func submitRating(for event: Event, rating: Int) {
        guard let userID = userID else {
            print("Error: No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        let reviewRef = ref.child("events").child(event.id).child("reviews").childByAutoId()
        let reviewData: [String: Any] = [
            "userID": userID,
            "rating": rating
        ]
        reviewRef.setValue(reviewData) { error, _ in
            if let error = error {
                print("Error submitting rating: \(error.localizedDescription)")
            } else {
                print("Rating submitted successfully.")
            }
        }
    }




    // Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEvents = events.filter { isEventPending(startDate: $0.startDate) }
        } else {
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) && isEventPending(startDate: $0.startDate) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }



}
