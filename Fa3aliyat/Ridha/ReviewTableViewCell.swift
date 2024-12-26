import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!  // Label to display user's name
    @IBOutlet weak var starsStackView: UIStackView!  // StackView for star ratings

    // Set up the cell with review data
    func setupCell(fullName: String, rating: Int) {
        userNameLabel.text = fullName  // Set the full name in the label
        
        // Update stars based on the rating
        updateStars(rating: rating)
    }

    // Update the stars based on the rating
    private func updateStars(rating: Int) {
        // Remove existing stars before adding new ones
        starsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalStars = 5
        for i in 1...totalStars {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            if i <= rating {
                starImageView.image = UIImage(systemName: "star.fill")  // Filled star
            } else {
                starImageView.image = UIImage(systemName: "star")  // Empty star
            }
            starsStackView.addArrangedSubview(starImageView)
        }
    }
}
