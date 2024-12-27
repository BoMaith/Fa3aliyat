import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChangeInterestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let allInterests = [
        ("Arts & Entertainment", "Arts"),
        ("Sports & Fitness", "Sport"),
        ("Food & Drink", "Food"),
        ("Technology & Innovation", "Tech"),
        ("Social & Networking", "Social"),
        ("Health & Wellness", "Health"),
        ("Education & Personal Growth", "Edu"),
        ("Family & Kids", "Family"),
        ("Islamic Religion", "Islam"),
        ("Gaming & E-sports", "Gaming"),
        ("Science & Discovery", "Science"),
        ("Shopping & Markets", "Shopping")
    ] // List of all possible interests
    
    var selectedInterests: [String: Bool] = [:] // Dictionary to store selected interests
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchUserInterests()
    }
    
    func fetchUserInterests() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        
        let userID = user.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("interests").observeSingleEvent(of: .value) { snapshot in
            if let interests = snapshot.value as? [String] {
                // Initialize all interests to false
                for interest in self.allInterests {
                    self.selectedInterests[interest.1] = false
                }
                // Set selected interests to true based on fetched data
                for interest in interests {
                    self.selectedInterests[interest] = true
                }
                self.tableView.reloadData()
            } else {
                // Initialize all interests to false if no interests found
                for interest in self.allInterests {
                    self.selectedInterests[interest.1] = false
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        
        let userID = user.uid
        let ref = Database.database().reference()
        let selectedInterestKeys = selectedInterests.filter { $0.value }.map { $0.key }
        
        ref.child("users").child(userID).child("interests").setValue(selectedInterestKeys) { error, _ in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save interests: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Interests updated successfully!")
            }
        }
    }
    
    // Helper function for alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Function to update interests in real-time database when toggled
    private func updateInterestInDatabase(interest: String, isSelected: Bool) {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        
        let userID = user.uid
        let ref = Database.database().reference()
        
        if isSelected {
            // Add interest to the database
            ref.child("users").child(userID).child("interests").child(interest).setValue(true)
        } else {
            // Remove interest from the database
            ref.child("users").child(userID).child("interests").child(interest).removeValue()
        }
    }
}

extension ChangeInterestsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInterests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath) as! ChangeInterestsTableViewCell
        let interest = allInterests[indexPath.row]
        cell.lblInterest.text = interest.0 // Use the first element of the tuple
        cell.switchInterest.isOn = selectedInterests[interest.1] == true // Use the second element of the tuple
        cell.switchInterest.tag = indexPath.row
        cell.switchInterest.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        return cell
    }
    
    @objc func switchToggled(_ sender: UISwitch) {
        let interest = allInterests[sender.tag].1 // Use the second element of the tuple
        selectedInterests[interest] = sender.isOn
        updateInterestInDatabase(interest: interest, isSelected: sender.isOn)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let interest = allInterests[indexPath.row].1 // Use the second element of the tuple
        selectedInterests[interest] = !(selectedInterests[interest] ?? false)
        updateInterestInDatabase(interest: interest, isSelected: selectedInterests[interest] ?? false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
