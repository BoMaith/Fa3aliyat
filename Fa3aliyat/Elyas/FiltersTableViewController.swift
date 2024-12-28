import UIKit

class FiltersTableViewController: UITableViewController {
    weak var delegate: FilterDelegate?

    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var selectedPriceRow: IndexPath? // Tracks the selected row for "Filter by Price"
    var selectedAgeRow: IndexPath?   // Tracks the selected row for "Filter by Age"
    var selectedButtonLabel: String? // Property to receive the selected row's label
    
    var selectedDate: Date?  // Stores selected Date (from a DatePicker), initially nil
    var selectedTime: Date?  // Stores selected Time (from a TimePicker), initially nil
    var selectedLocation: String?  // Stores selected location (text input)
    
    var selectedFilters: [Any?] = [nil, nil, nil, nil, nil, nil] // [category, date, time, price, location, age]

    
    override func loadView() {
        super.loadView()
        //print("loadView is called") // See if this is ever triggered.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()

        self.tabBarController?.tabBar.isHidden = true
        clearAllSelections()

        // Set the UITextField's delegate
        locationTextField.delegate = self
        
        // Add a gesture recognizer to detect taps outside of the input field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // Allow touches on table view cells
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
        
//        let locale = Locale(identifier: "en_GB")  // Locale that uses 24-hour format
//        timePicker.locale = locale
    }

    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        // Dismiss keyboard if tap is outside the UITextField
        if !locationTextField.frame.contains(sender.location(in: view)) {
            locationTextField.resignFirstResponder() // Dismiss the keyboard
        }
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

        // Save Date
        if let date = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            selectedFilters[1] = dateFormatter.string(from: date)
        }

        // Save Time
        if let time = selectedTime {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            selectedFilters[2] = timeFormatter.string(from: time)
        }

        // Save Price using a switch statement into the selectedFilters array at index 2
        if let priceIndex = selectedPriceRow?.row {  // Check if any price row is selected
            switch priceIndex {
            case 0:
                selectedFilters[3] = "Free" // Save to selectedFilters array
                print("Saved selected price: Free")
            case 1:
                selectedFilters[3] = "0.1 - 4.9 BD" // Save to selectedFilters array
                print("Saved selected price: 0.1 - 4.9 BD")
            case 2:
                selectedFilters[3] = "5 - 9.9 BD" // Save to selectedFilters array
                print("Saved selected price: 5 - 9.9 BD")
            case 3:
                selectedFilters[3] = "10 - 19.9 BD" // Save to selectedFilters array
                print("Saved selected price: 10 - 19.9 BD")
            case 4:
                selectedFilters[3] = "20+ BD" // Save to selectedFilters array
                print("Saved selected price: 20+ BD")
            default:
                selectedFilters[3] = nil // Clear if no valid row is selected
                print("No valid price row selected")
            }
        }

        // Save Location
        if let location = selectedFilters[4] as? String {
            UserDefaults.standard.set(location, forKey: "selectedLocation")
        }

        // Save Age using a switch statement into the selectedFilters array at index 4
        if let ageIndex = selectedAgeRow?.row {  // Check if any age row is selected
            switch ageIndex {
            case 0:
                selectedFilters[5] = "Family-Friendly" // Save to selectedFilters array
                print("Saved selected age: Family-Friendly")
            case 1:
                selectedFilters[5] = "12 - 18 years" // Save to selectedFilters array
                print("Saved selected age: 12 - 18 years")
            case 2:
                selectedFilters[5] = "18+ years" // Save to selectedFilters array
                print("Saved selected age: 18+ years")
            default:
                selectedFilters[5] = nil // Clear if no valid row is selected
                print("No valid age row selected")
            }
        }

        // Save the selected filters in UserDefaults
        for (index, filter) in selectedFilters.enumerated() {
            if let filter = filter as? String {
                let key = "selectedFilter\(index)"
                UserDefaults.standard.set(filter, forKey: key)
            }
        }

        print("Filters saved: \(selectedFilters)")
        
        // Now pop the current view controller to go back to the SearchPage
        // Ensure the selectedFilters are passed back to SearchPage
        if let searchVC = navigationController?.viewControllers.first(where: { $0 is SearchViewController }) as? SearchViewController {
            searchVC.filtersArray = selectedFilters
        }
        
        // Pass the selected filters back to the delegate
        delegate?.didApplyFilters(selectedFilters)
        navigationController?.popViewController(animated: true) // Pop to the previous screen (SearchPage)
    }






    // Handle Date and Time Selection
    // MARK: - Actions for Date and Time
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
        selectedFilters[1] = selectedDate // Update date in the filters array
    }

    @IBAction func timeSelected(_ sender: UIDatePicker) { // New Action for Time Picker
        selectedTime = sender.date
        selectedFilters[2] = selectedTime // Update time in the filters array
    }

    @IBAction func locationChanged(_ sender: UITextField) {
        if let text = sender.text {
            selectedLocation = text
            selectedFilters[4] = selectedLocation // Store location in selectedFilters[5]
        }
    }

    // Update filters with current selections
//    private func updateSelectedFilters() {
//        if let date = selectedDate {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .short
//            dateFormatter.timeStyle = .short
//            selectedFilters[1] = dateFormatter.string(from: date)
//        }
//    }

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
        // Check if the same row is tapped again (deselect it)
        if selectedPriceRow == indexPath {
            // Deselect the row by removing the checkmark
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none // Remove the checkmark
            }
            // Remove the selection from the model (optional, depending on your logic)
            selectedPriceRow = nil
            selectedFilters[3] = nil
        } else {
            // If a different row is selected, remove the checkmark from the previously selected row
            if let previouslySelectedIndexPath = selectedPriceRow {
                if let previouslySelectedCell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                    previouslySelectedCell.accessoryType = .none // Remove checkmark
                }
            }
            
            // Set the new row as selected and add the checkmark
            selectedPriceRow = indexPath
            if let newSelectedCell = tableView.cellForRow(at: indexPath) {
                newSelectedCell.accessoryType = .checkmark // Add checkmark to the new selected row
            }
            
            // Update the filter model with the selected label (if necessary)
            if let newSelectedCell = tableView.cellForRow(at: indexPath) {
                selectedFilters[3] = newSelectedCell.textLabel?.text
            }
        }
        
        // Reload the row to ensure the accessory type is updated
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // Handle Age Selection
    private func handleAgeSelection(at indexPath: IndexPath) {
        // Check if the same row is tapped again (deselect it)
        if selectedAgeRow == indexPath {
            // Deselect the row by removing the checkmark
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none // Remove the checkmark
            }
            // Remove the selection from the model (optional, depending on your logic)
            selectedAgeRow = nil
            selectedFilters[5] = nil
        } else {
            // If a different row is selected, remove the checkmark from the previously selected row
            if let previouslySelectedIndexPath = selectedAgeRow {
                if let previouslySelectedCell = tableView.cellForRow(at: previouslySelectedIndexPath) {
                    previouslySelectedCell.accessoryType = .none // Remove checkmark
                }
            }
            
            // Set the new row as selected and add the checkmark
            selectedAgeRow = indexPath
            if let newSelectedCell = tableView.cellForRow(at: indexPath) {
                newSelectedCell.accessoryType = .checkmark // Add checkmark to the new selected row
            }
            
            // Update the filter model with the selected label (if necessary)
            if let newSelectedCell = tableView.cellForRow(at: indexPath) {
                selectedFilters[5] = newSelectedCell.textLabel?.text
            }
        }
        
        // Reload the row to ensure the accessory type is updated
        tableView.reloadRows(at: [indexPath], with: .none)
    }



    
    // Handle Price Selection
//    private func handlePriceSelection(at indexPath: IndexPath) {
//        // If the same row is tapped again, deselect it
//        if selectedPriceRow == indexPath {
//            selectedPriceRow = nil
//            selectedFilters[2] = nil
//        } else {
//            // Deselect previously selected row
//            if let previouslySelectedIndexPath = selectedPriceRow {
//                if let cell = tableView.cellForRow(at: previouslySelectedIndexPath) {
//                    cell.accessoryType = .none
//                }
//            }
//            selectedPriceRow = indexPath
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.accessoryType = .checkmark
//                selectedFilters[2] = cell.textLabel?.text // Store the label of the selected row
//            }
//        }
//        
//        // Reload the row to make sure the accessory type is updated
//        tableView.reloadRows(at: [indexPath], with: .none)
//    }
//
//    // Handle Age Selection
//    private func handleAgeSelection(at indexPath: IndexPath) {
//        // If the same row is tapped again, deselect it
//        if selectedAgeRow == indexPath {
//            selectedAgeRow = nil
//            selectedFilters[4] = nil
//        } else {
//            // Deselect previously selected row
//            if let previouslySelectedIndexPath = selectedAgeRow {
//                if let cell = tableView.cellForRow(at: previouslySelectedIndexPath) {
//                    cell.accessoryType = .none
//                }
//            }
//            selectedAgeRow = indexPath
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.accessoryType = .checkmark
//                selectedFilters[4] = cell.textLabel?.text // Store the label of the selected row
//            }
//        }
//        
//        // Reload the row to make sure the accessory type is updated
//        tableView.reloadRows(at: [indexPath], with: .none)
//    }

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

// UITextFieldDelegate method to dismiss keyboard on return key
extension FiltersTableViewController: UITextFieldDelegate {
    // Dismiss the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
}
protocol FilterDelegate: AnyObject {
    func didApplyFilters(_ filters: [Any?])
}
