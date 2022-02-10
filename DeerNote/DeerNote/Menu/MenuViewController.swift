//
//  MenuViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

protocol MenuViewControllerDeleagete: AnyObject {
    func didTap(_ vc: MenuViewController, mainMenu: MenuViewController.MainMenu)
    func didTap(_ vc: MenuViewController, tag: Tag)
}

class MenuViewController: UIViewController {
    enum MainMenu: String, CaseIterable {
        case all = "AllNote"
        case trash = "Trash"
        case settings = "Settings"
        case untagged = "Untagged"
    }
    
    // MARK: Properties
    weak var delegate: MenuViewControllerDeleagete?
    var tags: [Tag] = [
        Tag(name: "아무거나"),
        Tag(name: "내맘내맘")
    ]
    
    @IBOutlet weak var tagTableView: UITableView!
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: @IBAction

    @IBAction func tapAllNotes(_ sender: UIButton) {
        delegate?.didTap(self, mainMenu: .all)
    }
    
    @IBAction func tapTrash(_ sender: UIButton) {
        delegate?.didTap(self, mainMenu: .trash)
    }
    
    @IBAction func tapSettings(_ sender: UIButton) {
        delegate?.didTap(self, mainMenu: .settings)
    }
    @IBAction func tapUntagged(_ sender: UIButton) {
        delegate?.didTap(self, mainMenu: .untagged)
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


extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTap(self, tag: tags[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
