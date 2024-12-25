import UIKit

class FiltersTableViewController: UITableViewController {

    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    
    var selectedPriceRow: IndexPath? // Tracks the selected row for "Filter by Price"
    var selectedAgeRow: IndexPath?   // Tracks the selected row for "Filter by Age"
    var selectedButtonLabel: String? // Property to receive the selected row's label
    
    var selectedDate: Date?  // Stores selected Date (from a DatePicker), initially nil
    var selectedTime: Date?  // Stores selected Time (from a TimePicker), initially nil
    var selectedLocation: String?  // Stores selected location (text input)
    
    var selectedFilters: [Any?] = [nil, nil, nil, nil, nil] // [category, dateAndTime, price, location, age]

    
    override func loadView() {
        super.loadView()
        print("loadView is called") // See if this is ever triggered.
    }
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        print("Delegate and DataSource connected: \(tableView.delegate != nil && tableView.dataSource != nil)")

        
        super.viewDidLoad()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        print("Table view loaded")

        self.tabBarController?.tabBar.isHidden = true
        clearAllSelections()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if let savedCategory = UserDefaults.standard.string(forKey: "selectedCategory") {
            categoryButton.setTitle(savedCategory, for: .normal)
            selectedButtonLabel = savedCategory
            selectedFilters[0] = savedCategory // Store category in selectedFilters[0]
        } else {
            categoryButton.setTitle("Select Category", for: .normal)
            selectedFilters[0] = "Select Category" // Default value
        }
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFilters))
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func saveFilters() {
        
        // Check if the category has been changed from "Select Category"
        if let categoryTitle = categoryButton.titleLabel?.text, categoryTitle != "Select Category" {
            selectedFilters[0] = categoryTitle
            print("Category selected: \(categoryTitle)")
        } else {
            selectedFilters[0] = nil // Do not save category if still "Select Category"
            print("Category not selected or still default.")
        }
        
        // Save Date and Time as a combined string
        if let dateAndTime = selectedFilters[1] as? String {
            UserDefaults.standard.set(dateAndTime, forKey: "selectedDateAndTime") // Save combined date and time
        }

        // Save Price
        if let price = selectedFilters[2] as? String {
            UserDefaults.standard.set(price, forKey: "selectedPrice")
        }

        // Save Location
        if let location = selectedFilters[3] as? String {
            UserDefaults.standard.set(location, forKey: "selectedLocation")
        }

        // Save Age
        if let age = selectedFilters[4] as? String {
            UserDefaults.standard.set(age, forKey: "selectedAge")
        }

        print("Filters saved: \(selectedFilters)")
    }

    // Handle Date and Time Selection
    @IBAction func dateTimeSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
        selectedTime = sender.date // Since we have one picker for both date and time
        updateSelectedFilters() // Update filters array when date and time are selected
    }

    @IBAction func locationChanged(_ sender: UITextField) {
        if let text = sender.text {
            selectedLocation = text
            selectedFilters[3] = selectedLocation // Store location in selectedFilters[3]
        }
    }

    // Update filters with current selections
    private func updateSelectedFilters() {
        if let date = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            selectedFilters[1] = dateFormatter.string(from: date)
        }
    }

    // MARK: - Table View Delegate Method for Row Selection (Price and Age)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected: section \(indexPath.section), row \(indexPath.row)") // Add this to check if the method is called

        // Check if the row belongs to price section or age section
        if indexPath.section == 2 { // Price section
            handlePriceSelection(at: indexPath)
        } else if indexPath.section == 4 { // Age section
            handleAgeSelection(at: indexPath)
        }
        
        // Deselect row to remove highlight
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Handle Price Selection
    private func handlePriceSelection(at indexPath: IndexPath) {
        // If the same row is tapped again, deselect it
        if selectedPriceRow == indexPath {
            selectedPriceRow = nil
            selectedFilters[2] = nil
        } else {
            // Deselect previously selected row
            if let previouslySelectedIndexPath = selectedPriceRow {
                if let cell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                    cell.accessoryType = .none
                }
            }
            selectedPriceRow = indexPath
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                selectedFilters[2] = cell.textLabel?.text // Store the label of the selected row
            }
        }
        
        // Reload the row to make sure the accessory type is updated
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // Handle Age Selection
    private func handleAgeSelection(at indexPath: IndexPath) {
        // If the same row is tapped again, deselect it
        if selectedAgeRow == indexPath {
            selectedAgeRow = nil
            selectedFilters[4] = nil
        } else {
            // Deselect previously selected row
            if let previouslySelectedIndexPath = selectedAgeRow {
                if let cell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                    cell.accessoryType = .none
                }
            }
            selectedAgeRow = indexPath
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                selectedFilters[4] = cell.textLabel?.text // Store the label of the selected row
            }
        }
        
        // Reload the row to make sure the accessory type is updated
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // Clear all selections
    private func clearAllSelections() {
        selectedPriceRow = nil
        selectedAgeRow = nil
        selectedDate = nil
        selectedTime = nil
        selectedLocation = nil

        // Clear checkmarks in price and age sections
        for section in [2, 4] {
            let numberOfRows = tableView.numberOfRows(inSection: section)
            for row in 0..<numberOfRows {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    cell.accessoryType = .none
                }
            }
        }
    }
}
