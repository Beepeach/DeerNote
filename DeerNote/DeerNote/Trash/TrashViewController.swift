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
        performFetch()
    }
    
    private func performFetch() {
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
        guard let deletedNotesCount = fetchedResultsController.sections?.first?.numberOfObjects else {
            return
        }
        
        removeNotesWithNoSave(count: deletedNotesCount)
        CoreDataManager.shared.saveMainContext()
    }
    
    private func removeNotesWithNoSave(count: Int) {
        (0 ..< count).forEach {
            guard let note = fetchedResultsController.sections?.first?.objects?[$0] as? NoteEntity else {
                return
            }
            NoteManager.shared.deleteWithNoSave(note: note)
        }
    }
    
    // MARK: Deinitializer
    deinit {
        print(#function, "TrashVC")
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
        setupCellText(cell, with: targetNote)
        return cell
    }
    
    private func setupCellText(_ cell: DeletedNoteTableViewCell, with targetNote: NoteEntity) {
        cell.contentLabel.text = targetNote.contents
        cell.deletedDdayLabel.text = shortDateFormatter.string(for: targetNote.deletedDate)
        cell.detailTextLabel?.textColor = .systemRed
    }
}


// MARK: - UITableViewDelegate
extension TrashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = setupDeleteAction(at: indexPath)
        let restoreAction = setupRestoreAction(at: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [restoreAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    private func setupDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") {[weak self] action, view, completion in
            self?.deleteNote(at: indexPath, completion: completion)
        }
        deleteAction.image = UIImage(systemName: "trash.slash")
        
        return deleteAction
    }
    
    private func deleteNote(at indexPath: IndexPath, completion: (Bool) -> Void) {
        let targetNote = fetchedResultsController.object(at: indexPath)
        NoteManager.shared.delete(note: targetNote)
        completion(true)
    }
    
    private func setupRestoreAction(at indexPath: IndexPath) -> UIContextualAction {
        let restoreAction = UIContextualAction(style: .normal, title: "복구") { [weak self] action, view, completion in
            self?.restoreNote(at: indexPath, completion: completion)
        }
        restoreAction.backgroundColor = .systemGreen
        restoreAction.image = UIImage(systemName: "arrow.clockwise")
        
        return restoreAction
    }
    
    private func restoreNote(at indexPath: IndexPath, completion: (Bool) -> Void) {
        let targetNote = fetchedResultsController.object(at: indexPath)
        NoteManager.shared.restore(note: targetNote)
        NotificationCenter.default.post(name: .noteDidRestore, object: nil)
        completion(true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrashViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        deletedNotesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndex = newIndexPath {
                deletedNotesTableView.insertRows(at: [insertIndex], with: .automatic)
            }
        case .delete:
            if let deletedIndex = indexPath {
                deletedNotesTableView.deleteRows(at: [deletedIndex], with: .fade)
            }
        case .move:
            if let sourceIndex = indexPath, let destinationIndex = newIndexPath {
                deletedNotesTableView.moveRow(at: sourceIndex, to: destinationIndex)
            }
        case .update:
            if let updatedIndex = newIndexPath {
                deletedNotesTableView.reloadRows(at: [updatedIndex], with: .fade)
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        deletedNotesTableView.endUpdates()
    }
}
