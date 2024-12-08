import UIKit

class InterestsTableViewCell: UITableViewCell {

    // Outlets

    @IBOutlet weak var switchInterest: UISwitch!
    @IBOutlet weak var imgInterestIcon: UIImageView!
    @IBOutlet weak var lblInterest: UILabel!

    func setupCell(photoName: String, name: String) {
        imgInterestIcon.image = UIImage(named: photoName)
        lblInterest.text = name
    }
}
