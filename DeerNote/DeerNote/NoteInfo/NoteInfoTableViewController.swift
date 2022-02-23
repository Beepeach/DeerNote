//
//  NoteInfoTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/23/22.
//

import UIKit

class NoteInfoTableViewController: UITableViewController {
    // MARK: Properties
    var targetNote: NoteEntity?
    private var isPinned: Bool? {
        guard let targetNote = targetNote else {
            return nil
        }
        return targetNote.customSortIndex < 0 ? true : false
    }
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd  HH:mm:ss"
        
        return formatter
    }()

    // MARK: @IBOutlet
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var modifiedDateLabel: UILabel!
    @IBOutlet weak var pinSwitch: UISwitch!
    
    // MARK: @IBAction
    @IBAction func tapPinSwitch(_ sender: UISwitch) {
        // TODO: - 스위치에 따라 pin을 하고 coredata업데이트
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
    }
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLables()
        setupPinSwitch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .noteInfoVCWillDisappear, object: nil)
    }
    
    private func setupDateLables() {
        createdDateLabel.text = dateFormatter.string(for: targetNote?.createdDate)
        modifiedDateLabel.text = dateFormatter.string(for: targetNote?.modifiedDate)
    }
    
    private func setupPinSwitch() {
        guard let isPinned = isPinned else {
            return
        }

        pinSwitch.isOn = isPinned
    }
    

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 ? true : false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            // TODO: - 삭제하고 dismiss 구현
        }
    }
}


extension Notification.Name {
    static let noteInfoVCWillDisappear = Notification.Name("noteInfoVCWillDisappear")
}
