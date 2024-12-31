import UIKit

class ParticipantTableViewCell: UITableViewCell {

    // Outlets for name label and profile image
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
//        profileImage.clipsToBounds = true
    }

    // This method sets up the cell with the participant's name and image
    func setupCell(name: String, image: UIImage?) {
        nameLabel.text = name  // Set the name label to the participant's name
        profileImage.image = image  // Set the profile image
    }
}
