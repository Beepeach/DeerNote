//
//  SettingsTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/27/22.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBAction func tapDoneBatButtonItem(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .systemTeal
    }
}
