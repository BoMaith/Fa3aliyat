import UIKit

class FiltersTableViewController: UITableViewController {

    @IBOutlet weak var categoryButton: UIButton!
    
    var selectedRows: Set<IndexPath> = []
    var selectedButtonLabel: String? // Property to receive the selected row's label

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure ticks are hidden initially
        tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = true

        // Retrieve the saved filter from UserDefaults if available
        if let savedCategory = UserDefaults.standard.string(forKey: "selectedCategory") {
            categoryButton.setTitle(savedCategory, for: .normal)
            selectedButtonLabel = savedCategory
        } else {
            // If there's no saved category, show default title
            categoryButton.setTitle("Select Category", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the label is not set (this means we're not coming from Categories), set it to "Select Category"
        if selectedButtonLabel == nil {
            categoryButton.setTitle("Select Category", for: .normal)
        } else {
            categoryButton.setTitle(selectedButtonLabel, for: .normal)
        }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        // Hide tick initially
        if let tickImageView = cell.contentView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            tickImageView.isHidden = !selectedRows.contains(indexPath)
        }

        return cell
    }

    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        // Toggle selection state
        if selectedRows.contains(indexPath) {
            selectedRows.remove(indexPath)
            hideTickIcon(in: cell)
        } else {
            selectedRows.insert(indexPath)
            showTickIcon(in: cell)
        }

        // Deselect row to remove highlight effect
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Helper Methods
    private func showTickIcon(in cell: UITableViewCell) {
        if let tickImageView = cell.contentView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            tickImageView.isHidden = false
        }
    }

    private func hideTickIcon(in cell: UITableViewCell) {
        if let tickImageView = cell.contentView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            tickImageView.isHidden = true
        }
    }

    // MARK: - Save the selected filter when the user presses the category button
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        // When a category is selected, save it to UserDefaults
        if let selectedCategory = categoryButton.title(for: .normal) {
            UserDefaults.standard.set(selectedCategory, forKey: "selectedCategory")
        }
    }
}
