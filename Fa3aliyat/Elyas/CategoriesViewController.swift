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

        // Track the state of switches
        var switchStates = [Bool](repeating: false, count: 12)

        // MARK: - Update Skip Button Title


        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return interests.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath) as! InterestsTableViewCell

            let (name, icon) = interests[indexPath.row]
            cell.setupCell(photoName: icon, name: name)
            
            // Add target action for the switch
            return cell
        }

        // MARK: - TableView Delegate Methods
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
