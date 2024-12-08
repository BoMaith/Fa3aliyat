import UIKit

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    @IBOutlet weak var skipBarBtn: UIBarButtonItem!
//    @IBOutlet weak var switchInterest: UISwitch!
    
    // Data for the table view
    let interests = [
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
    ]

    // Table view
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath) as! InterestsTableViewCell

        let (name, icon) = interests[indexPath.row]
        cell.setupCell(photoName: icon, name: name)

        return cell
    }

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    @objc func switchChanged() {
//            // Check if any switch is turned on
//            if switchInterest.isOn {
//                skipBarBtn.title = "Done"
//            } else {
//                skipBarBtn.title = "Skip"
//            }
//        }
}
