//
//  AETableViewCell.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 17/12/2024.
//

import UIKit

class AETableViewCell: UITableViewCell {
    @IBOutlet weak var timePkr: UIDatePicker!
    @IBOutlet weak var loctxtfld: UITextField!
    @IBOutlet weak var tTxtFld: UITextField!
    @IBOutlet weak var DscTxtFld: UITextField!
    @IBOutlet weak var sDatePkr: UIDatePicker!
    @IBOutlet weak var eDatePkr: UIDatePicker!
    @IBOutlet weak var PriceTxtFld: UITextField!
    @IBOutlet weak var AgeTxtFld: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Method to get data from the text fields and date pickers
        func getEventData() -> [String: Any] {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let time = formatter.string(from: timePkr.date)
            let startDate = formatter.string(from: sDatePkr.date)
            let endDate = formatter.string(from: eDatePkr.date)

            return [
                "title": tTxtFld.text ?? "",
                "description": DscTxtFld.text ?? "",
                "location": loctxtfld.text ?? "",
                "price": PriceTxtFld.text ?? "",
                "age": AgeTxtFld.text ?? "",
                "time": time,
                "startDate": startDate,
                "endDate": endDate
            ]
        }
    
    // MARK: - Method to configure the cell with data (optional, if using pre-filled data)
       func configureCell(with data: [String: Any]?) {
           // This function can be used if you want to pre-populate the fields with existing data
           if let data = data {
               tTxtFld.text = data["title"] as? String
               DscTxtFld.text = data["description"] as? String
               loctxtfld.text = data["location"] as? String
               PriceTxtFld.text = data["price"] as? String
               AgeTxtFld.text = data["age"] as? String

               // Set values for the date pickers (start and end dates)
               if let startDate = data["startDate"] as? String {
                   let formatter = DateFormatter()
                   formatter.dateStyle = .medium
                   formatter.timeStyle = .short
                   if let date = formatter.date(from: startDate) {
                       sDatePkr.date = date
                   }
               }

               if let endDate = data["endDate"] as? String {
                   let formatter = DateFormatter()
                   formatter.dateStyle = .medium
                   formatter.timeStyle = .short
                   if let date = formatter.date(from: endDate) {
                       eDatePkr.date = date
                   }
               }

               // Set the time picker (if applicable)
               if let time = data["time"] as? String {
                   let formatter = DateFormatter()
                   formatter.dateStyle = .medium
                   formatter.timeStyle = .short
                   if let date = formatter.date(from: time) {
                       timePkr.date = date
                   }
               }
           }
       }

}
