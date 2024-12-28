//import UIKit
//import FirebaseAuth
//import FirebaseDatabase
//
//class ChangeInterestsViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//
//    let allInterests = [
//        ("Arts & Entertainment", "Arts"),
//        ("Sports & Fitness", "Sport"),
//        ("Food & Drink", "Food"),
//        ("Technology & Innovation", "Tech"),
//        ("Social & Networking", "Social"),
//        ("Health & Wellness", "Health"),
//        ("Education & Personal Growth", "Edu"),
//        ("Family & Kids", "Family"),
//        ("Islamic Religion", "Islam"),
//        ("Gaming & E-sports", "Gaming"),
//        ("Science & Discovery", "Science"),
//        ("Shopping & Markets", "Shopping")
//    ] // List of all possible interests
//    
//    var selectedInterests = [String]() // List to store selected interests
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        fetchUserInterests()
//    }
//
//    func fetchUserInterests() {
//        guard let user = Auth.auth().currentUser else {
//            print("No user is logged in")
//            return
//        }
//
//        let userID = user.uid
//        let ref = Database.database().reference()
//
//        ref.child("users").child(userID).child("interests").observeSingleEvent(of: .value) { snapshot in
//            if let interests = snapshot.value as? [String] {
//                self.selectedInterests = interests
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    @IBAction func saveButtonTapped(_ sender: UIButton) {
//        saveInterestsToFirebase()
//    }
//
//    private func saveInterestsToFirebase() {
//        guard let user = Auth.auth().currentUser else {
//            print("No user is logged in")
//            return
//        }
//
//        let userID = user.uid
//        let ref = Database.database().reference()
//
//        ref.child("users").child(userID).child("interests").setValue(selectedInterests) { error, _ in
//            if let error = error {
//                self.showAlert(title: "Error", message: "Failed to save interests: \(error.localizedDescription)")
//            } else {
//                self.showAlert(title: "Success", message: "Interests updated successfully!")
//            }
//        }
//    }
//
//    // Helper function for alerts
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    // Function to update interests in real-time database when toggled
//    private func updateInterestInDatabase(interest: String, isSelected: Bool) {
//        guard let user = Auth.auth().currentUser else {
//            print("No user is logged in")
//            return
//        }
//
//        let userID = user.uid
//        let ref = Database.database().reference()
//
//        if isSelected {
//            // Add interest to the list
//            if !selectedInterests.contains(interest) {
//                selectedInterests.append(interest)
//            }
//        } else {
//            // Remove interest from the list
//            if let index = selectedInterests.firstIndex(of: interest) {
//                selectedInterests.remove(at: index)
//            }
//        }
//
//        // Save the updated interests to the database
//        ref.child("users").child(userID).child("interests").setValue(selectedInterests)
//    }
//}
//
//extension ChangeInterestsViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return allInterests.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath) as! ChangeInterestsTableViewCell
//        let interest = allInterests[indexPath.row]
//        cell.lblInterest.text = interest.0 // Use the first element of the tuple
//        cell.switchInterest.isOn = selectedInterests.contains(interest.1) // Check if the interest is selected
//        cell.switchInterest.tag = indexPath.row
//        cell.switchInterest.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
//        return cell
//    }
//
//    @objc func switchToggled(_ sender: UISwitch) {
//        let interest = allInterests[sender.tag].1 // Use the second element of the tuple
//        updateInterestInDatabase(interest: interest, isSelected: sender.isOn)
//    }
//}


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
    
    var selectedInterests = [String]() // List to store selected interests
    var switchStates = [Bool](repeating: false, count: 12) // Track the state of switches

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
            if let interestsDictionary = snapshot.value as? [String: Bool] {
                self.selectedInterests = interestsDictionary.keys.filter { interestsDictionary[$0] == true }
                
                // Update switchStates based on selectedInterests
                for (index, interest) in self.allInterests.enumerated() {
                    if self.selectedInterests.contains(interest.0) {
                        self.switchStates[index] = true
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    // Function to update interests in real-time database when toggled
    private func updateInterestInDatabase() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let userID = user.uid
        let ref = Database.database().reference()
        var interestsDictionary = [String: Bool]()
        
        for (index, isOn) in switchStates.enumerated() {
            let interest = allInterests[index].0
            interestsDictionary[interest] = isOn
        }

        ref.child("users").child(userID).child("interests").setValue(interestsDictionary) { error, _ in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath) as! ChangeInterestsTableViewCell
        let interest = allInterests[indexPath.row]
        cell.lblInterest.text = interest.0 // Use the first element of the tuple
        cell.switchInterest.isOn = switchStates[indexPath.row] // Configure the switch state based on switchStates
        cell.switchInterest.tag = indexPath.row
        cell.switchInterest.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        return cell
    }

    @objc func switchToggled(_ sender: UISwitch) {
        switchStates[sender.tag] = sender.isOn
        updateInterestInDatabase() // Update interests in the database whenever a toggle changes
    }
}
