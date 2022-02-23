//
//  PopoverViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/22/22.
//

import UIKit

class PopoverViewController: UIViewController {
    var targetNote: NoteEntity?
    var index: Int?
    var isPinned: Bool?
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var pinSelectLabel: UILabel!
    
    @IBAction func tapPinButton(_ sender: UIButton) {
        // TODO: - Pin유무에 따라 note에 표시가 되는 기능을 추가하면 좋습니다!
        guard let targetNote = targetNote else {
            return
        }
        guard let isPinned = isPinned else {
            return
        }
        
        if isPinned == true {
            NoteManager.shared.update(targetNote, sortIndex: 0)
        } else {
            NoteManager.shared.update(targetNote, sortIndex: -1)
        }
        
        NotificationCenter.default.post(name: .notePinButtonDidTapped, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteInfoVC = segue.destination as? NoteInfoTableViewController else {
            return
        }
        guard let targetNote = targetNote else {
            return
        }
        
        noteInfoVC.targetNote = targetNote
    }
    
    @IBAction func tapTrashButton(_ sender: UIButton) {
        guard let targetNote = targetNote else {
            return
        }
        guard let index = index else {
            return
        }
        
        let alertController =  UIAlertController(title: "알림", message: "해당 노트를 삭제하시겠어요??", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let removeAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            NoteManager.shared.moveTrash(note: targetNote)
            NotificationCenter.default.post(name: .mainContextDidChange, object: nil, userInfo: ["index": index])
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 200, height: 150)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isPinned == true {
            pinSelectLabel.text = "상단 고정 해제"
            pinSelectLabel.textColor = .systemRed
            pinImageView.image = UIImage(systemName: "pin.slash")
            pinImageView.tintColor = .systemRed
        } else {
            pinSelectLabel.text = "상단 고정"
            pinImageView.image = UIImage(systemName: "pin.circle")
        }
    }
    
    deinit {
        print("Pop deinit")
    }
}

extension Notification.Name {
    static let mainContextDidChange = Notification.Name("mainContextDidChange")
    static let notePinButtonDidTapped = Notification.Name("noteDidPinned")
}

extension NoteListViewController {
    static let selectedNoteIndexUserInfoKey: String = "index"
}
