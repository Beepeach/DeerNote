//
//  MenuViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit
import CoreData

protocol MenuViewControllerDeleagete: AnyObject {
    func didTap(_ vc: MenuViewController, mainMenu: MenuViewController.MainMenu)
    func didTap(_ vc: MenuViewController, tag: TagEntity)
}

class MenuViewController: UIViewController {
    // MARK: Enum
    enum MainMenu: String, CaseIterable {
        case all = "AllNote"
        case trash = "Trash"
        case settings = "Settings"
        case untagged = "Untagged"
    }
    
    
    // MARK: Properties
    lazy var fetchedResultsController: NSFetchedResultsController<TagEntity> = {
        let tagNameASCESortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let fetchRequest: NSFetchRequest<TagEntity> = TagManager.shared.setupAllTagsFetchRequest(sort: [tagNameASCESortDescriptor])
        let controller: NSFetchedResultsController<TagEntity> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    weak var delegate: MenuViewControllerDeleagete?
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var tagTableView: UITableView!
    
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
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


// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTap(self, tag: fetchedResultsController.object(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension MenuViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
