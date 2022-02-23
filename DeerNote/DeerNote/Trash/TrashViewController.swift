//
//  TrashViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/14/22.
//

import UIKit
import CoreData

class TrashViewController: UIViewController {
    // MARK: Properties
    lazy var fetchedResultsController: NSFetchedResultsController<NoteEntity> = {
        let deletedDateDESCSortDescriptor = NSSortDescriptor(key: "deletedDate", ascending: false)
        let fetchRequest = NoteManager.shared.setupAllNoteFetchRequest(sort: [deletedDateDESCSortDescriptor], trash: true)
        // TODO: Cache를 사용할건지는 추후에 결정합시다.
        let fetchedResultsController: NSFetchedResultsController<NoteEntity> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: @IBOutlet
    @IBOutlet weak var deletedNotesTableView: UITableView!
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // MARK: @IBAction
    @IBAction func tapEmptyTrash(_ sender: Any) {
        presentTrashAlert()
    }
    
    private func presentTrashAlert() {
        let alertController = UIAlertController(title: nil, message: "휴지통을 모두 비우시겠어요?\n휴지통에서 삭제하면 더 이상 복구할 수 없습니다.", preferredStyle: .alert)
        let actions = createActions()
        actions.forEach { alertController.addAction($0) }

        present(alertController, animated: true, completion: nil)
    }
    
    private func createActions() -> [UIAlertAction] {
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let emptyAction = UIAlertAction(title: "비우기", style: .destructive, handler: { [weak self] _ in
            self?.removeAllTrash()
        })
        
        return [cancelAction, emptyAction]
    }
    
    private func removeAllTrash() {
//        let deletedNotesCount = self.deletedNotes.count
//        self.deletedNotesTableView.performBatchUpdates {
//            for i in 0 ..< deletedNotesCount {
//                self.deletedNotes.removeFirst()
//                self.deletedNotesTableView.deleteRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
//            }
//        }
    }
    
    deinit {
        print(#function)
        fetchedResultsController.delegate = nil
    }
}


// MARK: - UITableViewDataSource
extension TrashViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedNoteCell", for: indexPath) as? DeletedNoteTableViewCell else {
            return DeletedNoteTableViewCell()
        }
        let targetNote = fetchedResultsController.object(at: indexPath)
        cell.contentsLabel.text = targetNote.contents
        return cell
    }
}


// MARK: - UITableViewDelegate
extension TrashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = setupDeleteAction(at: indexPath)
        let restoreAction = setupRestoreAction(at: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [restoreAction, deleteAction])
        
        return configuration
    }
    
    private func setupDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, completion in
//            self.deletedNotes.remove(at: indexPath.row)
            self.deletedNotesTableView.deleteRows(at: [indexPath], with: .automatic)
            // TODO: - CoreData에서 삭제하는 코드가 들어가야합니다.
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.slash")
        
        return deleteAction
    }
    
    private func setupRestoreAction(at indexPath: IndexPath) -> UIContextualAction {
        let restoreAction = UIContextualAction(style: .normal, title: "복구") { action, view, completion in
//            self.deletedNotes[indexPath.row].isDeleted = false
//            self.deletedNotes.remove(at: indexPath.row)
            self.deletedNotesTableView.deleteRows(at: [indexPath], with: .automatic)
            // TODO: - CoreData에 deleted 속성을 변경시키는 코드가 들어가야합니다.
            completion(true)
        }
        restoreAction.backgroundColor = .systemGreen
        restoreAction.image = UIImage(systemName: "arrow.clockwise")
        
        return restoreAction
    }
}


extension TrashViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
}
