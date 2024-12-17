//
//  AEViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 17/12/2024.
//

import UIKit
import Firebase
import FirebaseDatabase

class AEViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.reloadData()

            // Setting up table view delegate and data source
            tableView.delegate = self
            tableView.dataSource = self

            // Registering the custom table view cell class (if not using a prototype cell in storyboard)
           tableView.register(AETableViewCell.self, forCellReuseIdentifier: "AETableViewCell")
            // Or, if you're using a nib file, register it like this:
            //let nib = UINib(nibName: "AETableViewCell", bundle: nil)
            //tableView.register(nib, forCellReuseIdentifier: "AETableViewCell")

            // Firebase reference setup
            ref = Database.database().reference()
        }

        // MARK: - TableView Delegate and DataSource Methods

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Dequeuing the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AETableViewCell", for: indexPath) as! AETableViewCell
            return cell
        }

        // MARK: - Saving Event Data to Firebase

        @IBAction func saveEventData(_ sender: Any) {
            // Accessing the cell to get the data and save to Firebase
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AETableViewCell {
                let eventData = cell.getEventData()

                // Saving event data to Firebase Realtime Database
                ref.child("events").childByAutoId().setValue(eventData) { error, ref in
                    if let error = error {
                        print("Error saving event data: \(error.localizedDescription)")
                    } else {
                        print("Event data saved successfully!")
                    }
                }
            }
        }
}
