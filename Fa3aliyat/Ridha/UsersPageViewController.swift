import UIKit

class UsersPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Step 1: Define the Organizer struct
    @IBOutlet weak var tableView: UITableView!
    struct Organizer {
        var name: String
        var email: String
    }
    
    // Array to store the organizers
    var organizers: [Organizer] = []

    // IBOutlet for the UITableView
    
    
    // Step 2: Table View Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerCellIdentifier", for: indexPath)
        
        // Get the current organizer
        let organizer = organizers[indexPath.row]
        
        // Configure the cell with organizer data
        cell.textLabel?.text = organizer.name
        cell.detailTextLabel?.text = organizer.email
        
        return cell
    }
    
    // Step 3: Navigation to the Create Organizer screen
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Ensure this is the segue to the CreateOrganizerViewController
        if let createOrganizerVC = segue.destination as? CreateOrganizerViewController {
            createOrganizerVC.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate and dataSource for the tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the default cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrganizerCellIdentifier")
    }
    
}

// Step 4: Conform to CreateOrganizerDelegate to handle new organizer creation
extension UsersPageViewController: CreateOrganizerDelegate {
    
    func didCreateOrganizer(_ organizer: Organizer) {
        // Step 5: Add the new organizer to the array and reload the table view
        organizers.append(organizer)
        tableView.reloadData()
    }
}
