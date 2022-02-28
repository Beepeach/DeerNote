//
//  SettingsTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/27/22.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    // MARK: @IBOutlet
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    // MARK: @IBAction
    @IBAction func toggleDarkModeSwitch(_ sender: UISwitch) {
        let userInterfaceStyle: Bool = sender.isOn
        UserDefaults.standard.setValue(userInterfaceStyle, forKey: "darkModeIsOn")
        self.view.window?.overrideUserInterfaceStyle = userInterfaceStyle ? .dark : .light
    }
    
    // MARK: VCLifeCycle
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
    
    
    // MARK: - UITableViewDataSouce
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: - 태그 정렬을 구현하면 삭제합시다.
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 1
        }
    }
}
