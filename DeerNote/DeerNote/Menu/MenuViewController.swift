//
//  MenuViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

protocol MenuViewControllerDeleagete: AnyObject {
    func buttonDidTapped(_ vc: UIViewController)
}

class MenuViewController: UIViewController {
    // MARK: Properties
    weak var delegate: MenuViewControllerDeleagete?
    
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    // MARK: @IBAction
    @IBAction func clickButton(_ sender: Any) {
        self.delegate?.buttonDidTapped(self)
    }
}
