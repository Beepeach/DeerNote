//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

class NoteListViewController: UIViewController {
    // MARK: @IBOutlet
    @IBOutlet weak var settingVCLeadingConstraint: NSLayoutConstraint!
    
    // MARK: @IBAction
    @IBAction func tapSetting(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3) {
            self.settingVCLeadingConstraint.constant = self.settingVCLeadingConstraint.constant == 0 ? -self.view.frame.width * 0.8 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialLayout()
        configureSearchBar()
    }
    
    private func setInitialLayout() {
        self.settingVCLeadingConstraint.constant = -self.view.frame.width * 0.8
    }
    
    private func configureSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
    }
}
