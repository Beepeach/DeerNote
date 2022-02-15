//
//  TrashViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/14/22.
//

import UIKit

class TrashViewController: UIViewController {
    // MARK: Properties
    var deletedNotes: [Note] = [
        // TODO: - CoreData에서 isDeleted가 true인 것들을 가져와야합니다.
        Note(contents: "잘있어요", tag: [], date: Date(), updatedDate: Date(), isDeleted: true),
        Note(contents: "더미더미", tag: [], date: Date(), updatedDate: Date(), isDeleted: true),
        Note(contents: "미더미더", tag: [], date: Date(), updatedDate: Date(), isDeleted: true),
        Note(contents: "크하하하하", tag: [], date: Date(), updatedDate: Date(), isDeleted: true),
        Note(contents: "안녕하세요. 반갑습니다 글자를 어디서부터 끊어야할지 잘 모르겠네요", tag: [], date: Date(), updatedDate: Date(), isDeleted: true),
        Note(contents: """
             반가워요
             이걸 어디서 끊어야할까요
             """, tag: [], date: Date(), updatedDate: Date(), isDeleted: true)
    ]
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var deletedNotesTableView: UITableView!
    
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let deletedNotesCount = self.deletedNotes.count
        self.deletedNotesTableView.performBatchUpdates {
            for i in 0 ..< deletedNotesCount {
                self.deletedNotes.removeFirst()
                self.deletedNotesTableView.deleteRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
            }
        }
    }
    
    deinit {
        print(#function)
    }
}


// MARK: - UITableViewDataSource
extension TrashViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deletedNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedNoteCell", for: indexPath) as? DeletedNoteTableViewCell else {
            return DeletedNoteTableViewCell()
        }
        cell.contentsLabel.text = deletedNotes[indexPath.row].contents
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
            self.deletedNotes.remove(at: indexPath.row)
            self.deletedNotesTableView.deleteRows(at: [indexPath], with: .automatic)
            // TODO: - CoreData에서 삭제하는 코드가 들어가야합니다.
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.slash")
        
        return deleteAction
    }
    
    private func setupRestoreAction(at indexPath: IndexPath) -> UIContextualAction {
        let restoreAction = UIContextualAction(style: .normal, title: "복구") { action, view, completion in
            self.deletedNotes[indexPath.row].isDeleted = false
            self.deletedNotes.remove(at: indexPath.row)
            self.deletedNotesTableView.deleteRows(at: [indexPath], with: .automatic)
            // TODO: - CoreData에 deleted 속성을 변경시키는 코드가 들어가야합니다.
            completion(true)
        }
        restoreAction.backgroundColor = .systemGreen
        restoreAction.image = UIImage(systemName: "arrow.clockwise")
        
        return restoreAction
    }
}
