//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

class NoteListViewController: UIViewController {
    @IBOutlet weak var settingVCLeadingConstraint: NSLayoutConstraint!
    
    @IBAction func tapSetting(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3) {
            self.settingVCLeadingConstraint.constant = self.settingVCLeadingConstraint.constant == 0 ? -self.view.frame.width * 0.8 : 0
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
        
        self.settingVCLeadingConstraint.constant = -self.view.frame.width * 0.8
    }
}
