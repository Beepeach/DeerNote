//
//  ViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/29/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuVCLeadingConstraint: NSLayoutConstraint!
    
    @IBAction func tapSetting(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3) {
            self.menuVCLeadingConstraint.constant = self.menuVCLeadingConstraint.constant == 0 ? -self.view.frame.width * 0.8 : 0
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
        
        self.menuVCLeadingConstraint.constant = -self.view.frame.width * 0.8
    }
}

