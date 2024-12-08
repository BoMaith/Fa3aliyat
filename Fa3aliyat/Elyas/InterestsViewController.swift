import UIKit

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets
    @IBOutlet weak var skipBarBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

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

    // Track the state of switches
    var switchStates = [Bool](repeating: false, count: 12)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        
        updateSkipButtonTitle()
    }

    // MARK: - Update Skip Button Title
    private func updateSkipButtonTitle() {
        let isAnySwitchOn = switchStates.contains(true)
        skipBarBtn.title = isAnySwitchOn ? "Done" : "Skip"
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath) as! InterestsTableViewCell

        let (name, icon) = interests[indexPath.row]
        cell.setupCell(photoName: icon, name: name)
        
        // Configure the switch state
        cell.switchInterest.isOn = switchStates[indexPath.row]
        
        // Add target action for the switch
        cell.switchInterest.tag = indexPath.row
        cell.switchInterest.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)

        return cell
    }

    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Switch Value Changed
    @objc func switchValueChanged(_ sender: UISwitch) {
        // Update the state of the corresponding switch
        switchStates[sender.tag] = sender.isOn
        
        // Update the skip button title
        updateSkipButtonTitle()
    }
}
