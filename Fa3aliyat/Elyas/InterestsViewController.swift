//
//  InterestsViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-201-17 on 04/12/2024.
//

import Foundation
import UIKit

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let interests = [
        "Arts & Entertainment",
        "Sports & Fitness",
        "Food & Drink",
        "Technology & Innovation",
        "Social & Networking",
        "Health & Wellness",
        "Education & Personal Growth",
        "Family & Kids",
        "Islamic Religion",
        "Gaming & E-sports",
        "Science & Discovery",
        "Shopping & Markets"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Table View DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath)
        cell.textLabel?.text = interests[indexPath.row]
        return cell
    }
}
