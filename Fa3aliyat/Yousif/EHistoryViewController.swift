//
//  EHistoryViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-15 on 26/12/2024.
//

import UIKit
import FirebaseDatabase

class EHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    struct Event {
        let id: String
        let title: String
        let date: String
        let icon: String
    }

    var userID: String = "ivb3nvgo3jYi3WJdA83KKjmWeJf2" // Hardcoded User ID for testing
    var upcomingEvents: [Event] = []
    var pastEvents: [Event] = []
    var filteredUpcomingEvents: [Event] = []
    var filteredPastEvents: [Event] = []

    // Firebase Realtime Database reference
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80

        searchBar.delegate = self
        // Fetch user's joined events
        fetchUserJoinedEvents()
    }

    // MARK: - Fetch User Joined Events
    func fetchUserJoinedEvents() {
        ref.child("users").child(userID).child("JoinedEvents").observeSingleEvent(of: .value) { snapshot in
            // Debugging: Print the snapshot value
            print("Snapshot Value: \(snapshot.value ?? "No data found")")

            // Handle JoinedEvents as a dictionary with numeric keys
            if let joinedEventsDict = snapshot.value as? [String: Any] {
                print("Joined Events Dictionary: \(joinedEventsDict)")

                // Extract event IDs from the dictionary
                let joinedEventIDs = joinedEventsDict.compactMap {
                    ($0.value as? [String: Any])?["id"] as? String
                }
                print("Joined Event IDs: \(joinedEventIDs)")

                if !joinedEventIDs.isEmpty {
                    // Fetch event details using the event IDs
                    self.fetchEventsDetails(eventIDs: joinedEventIDs)
                } else {
                    print("No event IDs found in JoinedEvents.")
                }
            } else {
                print("JoinedEvents has an unexpected structure or is empty.")
            }
        } withCancel: { error in
            print("Error fetching joined events: \(error.localizedDescription)")
        }
    }


    

    func fetchEventsDetails(eventIDs: [String]) {
        let eventRef = ref.child("events")

        eventRef.observeSingleEvent(of: .value) { snapshot in
            // Log the snapshot to see the structure
            print("Snapshot Value: \(snapshot.value ?? "No value")")
            
            if let eventsData = snapshot.value as? [String: [String: Any]] {
                // Log the event data to understand its structure
                print("Events Data: \(eventsData)")

                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjusted to match `startDate` and `endDate` formats
                
                

                for eventID in eventIDs {
                    // Check if the eventID exists in the events data
                    if let data = eventsData[eventID] {
                        // Log the data for each eventID
                        print("Event Data for \(eventID): \(data)")

                        if let title = data["name"] as? String,  // Changed "title" to "name" as per your structure
                           let startDateStr = data["timestamp"] as? String,  // Assuming timestamp is used
                           let startDate = dateFormatter.date(from: startDateStr) {

                            let event = Event(id: eventID, title: title, date: startDateStr, icon: "") // Assuming icon is empty for now

                            // Add to upcoming or past events
                            self.upcomingEvents.append(event)


                        } else {
                            print("Event data for \(eventID) is missing or invalid")
                        }
                    } else {
                        print("EventID \(eventID) not found in eventsData.")
                    }
                }

                // After fetching all the event details, update the filtered events
                print("Upcoming Events: \(self.upcomingEvents.count)") // Check how many events were classified
                print("Past Events: \(self.pastEvents.count)")

                self.filteredUpcomingEvents = self.upcomingEvents
                self.filteredPastEvents = self.pastEvents

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            } else {
                print("No events data found.")
            }
        } withCancel: { error in
            print("Error fetching event details: \(error.localizedDescription)")
        }
        
        
    }


    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Upcoming and Past events
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? filteredUpcomingEvents.count : filteredPastEvents.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Upcoming Events" : "Past Events"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Determine the event to display
        let event = indexPath.section == 0 ? filteredUpcomingEvents[indexPath.row] : filteredPastEvents[indexPath.row]
        print("Setting up cell for event: \(event.title), \(event.date), \(event.icon)")
          
        // Choose the appropriate cell identifier based on the section
        let cellIdentifier = indexPath.section == 0 ? "EPendingCell" : "EDoneCell"
        
        // Dequeue the appropriate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EHistoryTableViewCell

        // Set up the cell with event details
        cell.setupCell(photoName: event.icon, name: event.title, date: event.date, isFavorite: false)

        return cell
    }

    // MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUpcomingEvents = upcomingEvents
            filteredPastEvents = pastEvents
        } else {
            filteredUpcomingEvents = upcomingEvents.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            filteredPastEvents = pastEvents.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
}
