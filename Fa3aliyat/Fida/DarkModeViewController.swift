//
//  DarkModeViewController.swift
//  Fa3aliyat
//
//  Created by BP-36-224-09 on 28/12/2024.
//

import UIKit

class DarkModeViewController: UIViewController {

    @IBOutlet weak var toggleButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleButton.isUserInteractionEnabled = true
        let currentMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") ?? "light"
            toggleButton.setTitle(currentMode == "light" ? "Switch to Dark Mode" : "Switch to Light Mode", for: .normal)
    }
    
    
    @IBAction func changeModeButtonClicked(_ sender: UIButton) {
        // Get the current mode
        let currentMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") ?? "light"

        // Toggle the mode
        let newMode: UIUserInterfaceStyle = (currentMode == "light") ? .dark : .light
        UserDefaults.standard.set(newMode == .light ? "light" : "dark", forKey: "userInterfaceStyle")

        // Apply the new mode
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = newMode
                }
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = newMode
            }
        }

        // Optionally update the button title
        sender.setTitle(newMode == .light ? "Switch to Dark Mode" : "Switch to Light Mode", for: .normal)
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
