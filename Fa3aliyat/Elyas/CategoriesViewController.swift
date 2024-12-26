import UIKit

enum CategoriesMode {
    case filter // For filtering events while searching
    case choose // For choosing a category while creating an event
}

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Sample data for the categories
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

        // To track selected index paths
        var selectedIndexPaths: Set<IndexPath> = []

        // Delegate to pass selected category (only used in .choose mode)
        weak var delegate: CategoriesViewControllerDelegate?

        // Mode to differentiate between filtering and choosing
        var mode: CategoriesMode = .filter // Default to filtering mode

        override func viewDidLoad() {
            super.viewDidLoad()

            // Set up table view delegate and data source
            tableView.delegate = self
            tableView.dataSource = self

            // Add "Clear" button to the navigation bar if in filtering mode
            if mode == .filter {
                setupClearButton()
            }
        }

        // MARK: - Set up the Clear button in Categories page (Filter mode only)
        func setupClearButton() {
            let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearCategorySelection))
            navigationItem.rightBarButtonItem = clearButton
        }

        // MARK: - Clear selected category and navigate back to Filters page
        @objc func clearCategorySelection() {
            guard mode == .filter else { return } // Ensure this only applies in filter mode

            // Reset selected category in the FiltersPage
            if let navigationController = self.navigationController,
               let filtersVC = navigationController.viewControllers.first(where: { $0 is FiltersTableViewController }) as? FiltersTableViewController {
                filtersVC.selectedButtonLabel = nil
                filtersVC.categoryButton.setTitle("Select Category", for: .normal)
            }

            // Reset the UserDefaults to remove the saved filter
            UserDefaults.standard.removeObject(forKey: "selectedCategory")

            // Optionally, reset the table selection (uncheck all)
            selectedIndexPaths.removeAll()
            tableView.reloadData()

            // Navigate back to the Filters page
            navigationController?.popViewController(animated: true)
        }

        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return interests.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoriesTableViewCell

            // Initially, no checkmark
            cell.accessoryType = .none

            let (name, icon) = interests[indexPath.row]
            cell.setupCell(photoName: icon, name: name)

            // Set the checkmark based on whether the row is selected
            if selectedIndexPaths.contains(indexPath) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        }

        // MARK: - TableView Delegate Methods
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCategoryName = interests[indexPath.row].0 // Store the name of the selected category

            switch mode {
            case .filter:
                // Toggle the checkmark
                if selectedIndexPaths.contains(indexPath) {
                    selectedIndexPaths.remove(indexPath) // Deselect and remove the checkmark
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                } else {
                    selectedIndexPaths.insert(indexPath) // Select and add the checkmark
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }

                // Optionally, deselect the row
                tableView.deselectRow(at: indexPath, animated: true)

                // Pass the selected category name back to FiltersPage
                if let navigationController = self.navigationController,
                   let filtersVC = navigationController.viewControllers.first(where: { $0 is FiltersTableViewController }) as? FiltersTableViewController {
                    filtersVC.selectedButtonLabel = selectedCategoryName
                    filtersVC.categoryButton.setTitle(selectedCategoryName, for: .normal)
                }

                // Now pop back to Filters
                navigationController?.popViewController(animated: true)

            case .choose:
                // Directly pass the selected category back to the delegate
                delegate?.didSelectCategory(selectedCategoryName)
                navigationController?.popViewController(animated: true)
            }
        }
    }
