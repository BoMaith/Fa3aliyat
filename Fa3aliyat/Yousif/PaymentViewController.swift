//
//  PaymentViewController.swift
//  Fa3aliyat
//
//  Created by Student on 12/12/2024.
//

import UIKit

class PaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var arrMethods = [Method]()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        arrMethods.append(Method.init(type: "Card", photo: UIImage(named: "Card")!))
        arrMethods.append(Method.init(type: "Cash", photo: UIImage(named: "Cash")!))
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMethods.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentTableViewCell
        
        let data = arrMethods[indexPath.row]
        cell.setupCell(photo: data.photo, type: data.type)
        return cell
    }

}


struct Method{
    
    let type : String
    let photo : UIImage
}
