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
    
    @IBAction func tapTagEditButton(_ sender: Any) {
        // TODO: tableView Editing mode
        tagTableView.setEditing(true, animated: true)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}


// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTap(self, tag: fetchedResultsController.object(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let targetTagEntity = fetchedResultsController.object(at: indexPath)
            TagManager.shared.delete(tag: targetTagEntity)
            NotificationCenter.default.post(name: .tagDidRemoved, object: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        return
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension MenuViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tagTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let insertIndex = newIndexPath else {
                return
            }
            tagTableView.insertRows(at: [insertIndex], with: .automatic)
        case .delete:
            guard let deletedIndex = indexPath else {
                return
            }
            tagTableView.deleteRows(at: [deletedIndex], with: .fade)
        case .move:
            guard let sourceIndex = indexPath,
                  let destinationIndex = newIndexPath else {
                      return
                  }
            tagTableView.moveRow(at: sourceIndex, to: destinationIndex)
        case .update:
            guard let updatedIndex = newIndexPath else {
                return
            }
            tagTableView.reloadRows(at: [updatedIndex], with: .fade)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tagTableView.endUpdates()
    }
}
