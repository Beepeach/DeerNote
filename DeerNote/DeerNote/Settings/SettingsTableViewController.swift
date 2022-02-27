//
//  SettingsTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/27/22.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .systemTeal
        
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
