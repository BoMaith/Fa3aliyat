import UIKit

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Data for each section
    let categories = ["Pizza", "Education", "Events", "Food", "Gaming", "Health"]
    let priceRanges = ["Free", "1 - 4.9 BD", "5 - 9.9 BD", "10 - 19.9 BD", "20+ BD"]
    let ageGroups = ["Family-Friendly", "12 - 18 years", "18+ years"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.title = "Filters Page"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5  // 5 sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return categories.count  // Number of categories
        case 1:
            return 2  // Date & Time (2 rows: Date and Time)
        case 2:
            return priceRanges.count  // Number of price ranges
        case 3:
            return 1  // Location (1 row)
        case 4:
            return ageGroups.count  // Number of age groups
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0: // Categories (Icons)
            cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath)
            let categoryLabel = cell.viewWithTag(1) as? UILabel  // Assuming Label has tag 1
            let categoryImageView = cell.viewWithTag(2) as? UIImageView  // Assuming ImageView has tag 2
            categoryLabel?.text = categories[indexPath.row]
            categoryImageView?.image = UIImage(named: categories[indexPath.row].lowercased())  // Use appropriate image names
            
        case 1: // Date & Time
            cell = tableView.dequeueReusableCell(withIdentifier: "dateTimeCell", for: indexPath)
            if indexPath.row == 0 {
                let dateLabel = cell.viewWithTag(1) as? UILabel  // Assuming Label has tag 1
                dateLabel?.text = "Date"
                let dateValueLabel = cell.viewWithTag(2) as? UILabel  // Assuming Label has tag 2
                dateValueLabel?.text = "June 2024"  // Example date value
            } else {
                let timeLabel = cell.viewWithTag(1) as? UILabel
                timeLabel?.text = "Time"
                let timeValueLabel = cell.viewWithTag(2) as? UILabel
                timeValueLabel?.text = "8:00 AM"  // Example time value
            }
            
        case 2: // Price
            cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath)
            cell.textLabel?.text = priceRanges[indexPath.row]
            
        case 3: // Location
            cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            let locationLabel = cell.viewWithTag(1) as? UILabel  // Assuming Label has tag 1
            let locationField = cell.viewWithTag(2) as? UITextField  // Assuming TextField has tag 2
            locationLabel?.text = "City Name"
            locationField?.placeholder = "e.g. Sar"
            
        case 4: // Age Groups
            cell = tableView.dequeueReusableCell(withIdentifier: "ageCell", for: indexPath)
            cell.textLabel?.text = ageGroups[indexPath.row]
            if indexPath.row == 2 { // Example: Pre-select last row
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "FILTER BY CATEGORY"
        case 1: return "FILTER BY DATE & TIME"
        case 2: return "FILTER BY PRICE"
        case 3: return "FILTER BY LOCATION"
        case 4: return "FILTER BY AGE"
        default: return nil
        }
    }
}
