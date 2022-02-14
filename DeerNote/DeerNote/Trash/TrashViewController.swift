//
//  TrashViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/14/22.
//

import UIKit

class TrashViewController: UIViewController {
    var deletedNotes: [Note] = [
        Note(contents: "잘있어요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "더미더미", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "미더미더", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "크하하하하", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "안녕하세요. 반갑습니다 글자를 어디서부터 끊어야할지 잘 모르겠네요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: """
             반가워요
             이걸 어디서 끊어야할까요
             """, tag: [], date: Date(), updatedDate: Date(), isDeleted: false)
    ]
    
    @IBOutlet weak var deletedNotesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func tapEmptyTrash(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "휴지통을 모두 비우시겠어요?\n휴지통에서 삭제하면 더 이상 복구할 수 없습니다.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let emptyAction = UIAlertAction(title: "비우기", style: .destructive, handler: { [weak self] _ in
            guard let deletedNotesCount = self?.deletedNotes.count else {
                return
            }
            self?.deletedNotesTableView.performBatchUpdates {
                for i in 0 ..< deletedNotesCount {
                    self?.deletedNotes.removeFirst()
                    self?.deletedNotesTableView.deleteRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
                }
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(emptyAction)
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        print(#function)
    }
}


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
