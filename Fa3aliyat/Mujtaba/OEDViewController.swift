//
//  OEDViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 26/12/2024.
//

import UIKit
import FirebaseDatabase

class OEDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var smntControl: UISegmentedControl!
    @IBOutlet weak var DView: UIView!
    @IBOutlet weak var pView: UIView!
    @IBOutlet weak var RView: UIView!
    //participants outlets
    @IBOutlet weak var pTitle: UILabel!
    @IBOutlet weak var PTableView: UITableView!
    @IBOutlet weak var PTVC: ParticipantTableViewCell!
    
     // review outlets
    @IBOutlet weak var RTV: UITableView!
    
    
    var participantsList: [Participant] = []  // Array to hold participants data
    var eventID: String?  // Assume eventID is provided when selecting an event
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the eventID is set before proceeding
        
        
        // Initial state: show only the Details view
        DView.isHidden = false
        pView.isHidden = true
        RView.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Event Details"

        // Setup participants table view
        PTableView.delegate = self
        PTableView.dataSource = self
        
        // Fetch participants for the event once the view loads
        fetchParticipants()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        // Hide all views first
        DView.isHidden = true
        pView.isHidden = true
        RView.isHidden = true

        // Show the selected view
        switch sender.selectedSegmentIndex {
        case 0:
            self.title = "Event Details"
            DView.isHidden = false
        case 1:
            self.title = "Participants"
            pView.isHidden = false
            pTitle.text = "Loading participants..."
            fetchParticipants()  // Fetch participants when "Participants" is selected
        case 2:
            self.title = "Reviews"
            RView.isHidden = false
        default:
            break
        }
    }
    
    // MARK: - Fetch participants from Firebase
    private func fetchParticipants() {
        guard let eventID = eventID else {
            print("Event ID is missing.")
            return
        }
        
        let ref = Database.database().reference()
        
        // Fetch participants for this event from Firebase
        ref.child("events").child(eventID).child("participants").observeSingleEvent(of: .value) { snapshot in
            guard let participantsDict = snapshot.value as? [String: Any] else {
                print("No participants found for this event.")
                return
            }
            
            // Map the participant data to a Participant model
            self.participantsList = participantsDict.map { (key, value) -> Participant in
                let participantData = value as? [String: Any] ?? [:]
                let participant = Participant(
                    id: key,
                    name: participantData["name"] as? String ?? "Unknown",
                    email: participantData["email"] as? String ?? "No email",
                    price: participantData["price"] as? Double ?? 0.0
                )
                return participant
            }
            
            // Update the participant count in the title
            self.pTitle.text = "Participants: \(self.participantsList.count)"
            
            // Reload the participants table view
            self.PTableView.reloadData()
        }
    }

    // MARK: - TableView Methods for Participants
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsList.count  // Return the number of participants
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participant = participantsList[indexPath.row]
        
        // Dequeue the cell and cast it to ParticipantTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantTableViewCell
        
        // Set up the cell with participant's name
        cell.setupCell(name: participant.name)
        
        return cell
    }

    // MARK: - Participant Model
    struct Participant {
        var id: String
        var name: String
        var email: String
        var price: Double
    }

    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OEDViewController" {
            // Pass the selected eventID to the destination view controller
            if let adminEventVC = segue.destination as? AdminEventViewController {
                adminEventVC.eventID = self.eventID  // Set eventID
            }
        }
    }
}
