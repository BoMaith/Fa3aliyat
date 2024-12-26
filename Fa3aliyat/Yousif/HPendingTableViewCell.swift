import UIKit

class HPendingTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var imgEvent: UIImageView!
    
    func setupCell(photoName: String, name: String, date: String) {
        imgEvent.image = UIImage(named: photoName)
        eventNameLbl.text = name
        eventDateLbl.text = date
    }

    func setupCell2(name: String, date: String) {
        // Set event details
        eventNameLbl.text = name
        eventDateLbl.text = date
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
