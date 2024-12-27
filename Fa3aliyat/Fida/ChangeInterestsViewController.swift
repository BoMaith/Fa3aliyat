import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChangeInterestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allInterests = ["Food", "Sport", "Social", "Music", "Technology", "Art"] // List of all possible interests
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
                for interest in interests {
                    self.selectedInterests[interest] = true
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
}

extension ChangeInterestsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInterests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath)
        let interest = allInterests[indexPath.row]
        cell.textLabel?.text = interest
        cell.accessoryType = selectedInterests[interest] == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let interest = allInterests[indexPath.row]
        selectedInterests[interest] = !(selectedInterests[interest] ?? false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
