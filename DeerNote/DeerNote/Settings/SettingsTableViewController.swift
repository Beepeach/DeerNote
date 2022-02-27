//
//  SettingsTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/27/22.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBAction func toggleDarkModeSwitch(_ sender: UISwitch) {
        let userInterfaceStyle: Bool = sender.isOn
        UserDefaults.standard.setValue(userInterfaceStyle, forKey: "darkModeIsOn")
        self.view.window?.overrideUserInterfaceStyle = userInterfaceStyle ? .dark : .light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupVersionLabel()
        setupDarkModeSwitch()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemTeal
    }
    
    private func setupVersionLabel() {
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private func setupDarkModeSwitch() {
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeIsOn")
    }
}
