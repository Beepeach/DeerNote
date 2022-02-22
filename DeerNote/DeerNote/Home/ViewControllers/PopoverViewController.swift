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
    
    @IBAction func tapPinButton(_ sender: UIButton) {
        // TODO: - pin꼽기
        print("Pin")
    }
    
    @IBAction func tapInfoButton(_ sender: UIButton) {
        // TODO: - 정보창 modal로 표시
        print("Info")
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
    
    deinit {
        print("Pop deinit")
    }
}

extension Notification.Name {
    static let mainContextDidChange = Notification.Name("mainContextDidChange")
}
