import UIKit

class ParticipantTableViewCell: UITableViewCell {

    // Outlet for name label
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // This method sets up the cell with the participant's name
    func setupCell(name: String) {
        nameLabel.text = name  // Set the name label to the participant's name
    }
}
