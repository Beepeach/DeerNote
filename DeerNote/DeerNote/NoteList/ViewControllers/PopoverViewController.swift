//
//  PopoverViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/22/22.
//

import UIKit

class PopoverViewController: UIViewController {
    // MARK: Properties
    var targetNote: NoteEntity?
    var index: Int?
    var isPinned: Bool?
    
    // MARK: @IBOutlet
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var pinSelectLabel: UILabel!
    
    // MARK: @IBAction
    @IBAction func tapPinButton(_ sender: UIButton) {
        updateCustomSortIndex()
        NotificationCenter.default.post(name: .notePinButtonDidTapped, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func updateCustomSortIndex() {
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
    }
    
    @IBAction func tapTrashButton(_ sender: UIButton) {
        let alertController =  UIAlertController(title: "알림", message: "해당 노트를 삭제하시겠어요??", preferredStyle: .alert)
        setupTrashAlert(controller: alertController)
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupTrashAlert(controller: UIAlertController) {
        guard let targetNote = targetNote else {
            return
        }
        guard let index = index else {
            return
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let removeAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.moveTrash(targetNote: targetNote, at: index)
        }
        controller.addAction(cancelAction)
        controller.addAction(removeAction)
    }
    
    private func moveTrash(targetNote: NoteEntity, at index: Int) {
        NoteManager.shared.moveTrash(note: targetNote)
        NotificationCenter.default.post(name: .noteDidMoveTrash, object: nil, userInfo: ["id": targetNote.objectID])
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 200, height: 150)
     
        //TODO: - 현재 noti를 이용해서 dismiss 시키고 있는데 어떻게 해야 더 효율적인지 생각해봅시다.
        NotificationCenter.default.addObserver(forName: .noteInfoVCWillDisappear, object: nil, queue: .main) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isPinned == true {
            setupPinOptionButton(text: "상단 고정 해제", image: UIImage(named: "unpin"))
        } else {
            setupPinOptionButton(text: "상단 고정", image: UIImage(named: "pin"))
        }
    }
    
    private func setupPinOptionButton(text: String, image: UIImage?) {
        pinSelectLabel.text = text
        pinImageView.image = image
        
        if isPinned == true {
            pinSelectLabel.textColor = .systemRed
            pinImageView.tintColor = .systemRed
        }
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
    
    // MARK: Deinitializer
    deinit {
        print("Pop deinit")
    }
}
