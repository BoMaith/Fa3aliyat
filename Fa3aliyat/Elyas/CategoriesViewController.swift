//
//  CategoriesViewController.swift
//  Testing
//
//  Created by BP-36-224-10 on 17/12/2024.
//

import UIKit

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
    }

        // Data for the table view
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

    // Track selected rows
        var selectedIndexPaths: Set<IndexPath> = []

        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return interests.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoriesTableViewCell

            let (name, icon) = interests[indexPath.row]
            cell.setupCell(photoName: icon, name: name)
            
            // Show or hide the tick based on selection
            if selectedIndexPaths.contains(indexPath) {
                cell.imgTickIcon.image = UIImage(systemName: "checkmark") // Use system image
                cell.imgTickIcon.tintColor = .blue
            } else {
                cell.imgTickIcon.image = nil // No tick for unselected rows
            }
            
            return cell
        }

        // MARK: - TableView Delegate Methods
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.remove(indexPath) // Deselect if already selected
            } else {
                selectedIndexPaths.insert(indexPath) // Select row
            }
            tableView.reloadRows(at: [indexPath], with: .automatic) // Reload only the affected row
        }
    }


