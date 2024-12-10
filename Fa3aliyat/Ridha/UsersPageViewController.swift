import UIKit

class UsersPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    struct Organizer {
        var name: String
        var email: String
       
    }

    
    // Arrays to store users and organizers
    var organizers: [Organizer] = []
    var users: [String] = []  // Sample users
    
    var isOrganizersSelected: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and dataSource for the tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the default UITableViewCell class if not done in the storyboard
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrganizerCellIdentifier")
        
        // Update UI based on the initial selected segment
        updateAddButtonVisibility()
    }

    
    // Update Add Button visibility based on selected segment
    // This function updates the visibility of the add button based on the selected segment
    func updateAddButtonVisibility() {
        // Hide the plus button when "Users" is selected
        addButton.isHidden = !isOrganizersSelected
    }

    
    // Step 2: Table View Data Source Methods
    // This function will handle the swipe-to-delete functionality
    // This method will be used for swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Create a custom delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // Show the confirmation alert before actually deleting
            let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this organizer?", preferredStyle: .alert)
            
            // Add a "Delete" action
            let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                // Delete the item from the correct array (organizers or users)
                if self.isOrganizersSelected {
                    self.organizers.remove(at: indexPath.row)
                } else {
                    self.users.remove(at: indexPath.row)
                }
                // Remove the row from the table view
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            // Add a "Cancel" action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // Add actions to the alert
            alert.addAction(confirmDelete)
            alert.addAction(cancelAction)
            
            // Present the alert to the user
            self.present(alert, animated: true, completion: nil)
            
            // Call the completion handler to dismiss the swipe action
            completionHandler(true)
        }
        
        // Configure the swipe actions and return them
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false  // Prevents automatic deletion on full swipe
        
        return swipeActions
    }



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOrganizersSelected ? organizers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell of default type
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerCellIdentifier", for: indexPath)
        
        // Check if we're showing "Organizers" or "Users"
        if isOrganizersSelected {
            let organizer = organizers[indexPath.row]
            
            // Set the text for the name (and email if needed)
            cell.textLabel?.text = organizer.name  // Name label
            
            
            
        } else {
            let user = users[indexPath.row]
            
            // Set the text for the name
            cell.textLabel?.text = user
            
            // Optionally, set a default image for users, if needed
            // cell.imageView?.image = UIImage(named: "defaultUserImage")  // Optional image for users
        }
        
        return cell
    }



    
    // Step 3: Segmented Control Action
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        // Reload the table view to reflect the data for the selected segment
        tableView.reloadData()
        
        // Update the visibility of the plus button
        updateAddButtonVisibility()
    }
    
    // Step 4: Navigation to the Create Organizer screen
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createOrganizerVC = segue.destination as? CreateOrganizerViewController {
            createOrganizerVC.delegate = self
        }
    }
}

// Step 5: Conform to CreateOrganizerDelegate to handle new organizer creation
extension UsersPageViewController: CreateOrganizerDelegate {
    
    func didCreateOrganizer(_ organizer: Organizer) {
        // Add the new organizer to the array and reload the table view
        organizers.append(organizer)
        
        // Reload table data only if "Organizers" is selected
        if isOrganizersSelected {
            tableView.reloadData()
        }
    }
}
