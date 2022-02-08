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
    @IBOutlet weak var tagTableView: UITableView!
    var tags: [Tag] = [
        Tag(name: "아무거나"),
        Tag(name: "내맘내맘")
    ]
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    // MARK: @IBAction
    @IBAction func clickButton(_ sender: Any) {
        self.delegate?.buttonDidTapped(self)
    }
}


extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = tags[indexPath.row].name
        
        return cell
    }
}
