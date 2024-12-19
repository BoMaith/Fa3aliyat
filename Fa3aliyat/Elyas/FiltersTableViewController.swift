import UIKit

class FiltersTableViewController: UITableViewController {

    // Track selected rows
    var selectedRows: Set<IndexPath> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure ticks are hidden initially
        tableView.reloadData()
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
}
