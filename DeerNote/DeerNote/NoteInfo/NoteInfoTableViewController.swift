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
        return targetNote.pinnedDate == nil ? false : true
    }

    // MARK: @IBOutlet
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var modifiedDateLabel: UILabel!
    @IBOutlet weak var pinSwitch: UISwitch!
    
    // MARK: @IBAction
    @IBAction func tapDonButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapPinSwitch(_ sender: UISwitch) {
        updatePinnedDate()
        NotificationCenter.default.post(name: .notePinButtonDidTapped, object: nil)
    }
    
    private func updatePinnedDate() {
        guard let targetNote = targetNote else {
            return
        }
        guard let isPinned = isPinned else {
            return
        }
        
        if isPinned == true {
            NoteManager.shared.update(targetNote, pinnedDate: nil)
        } else {
            NoteManager.shared.update(targetNote, pinnedDate: Date())
        }
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
        createdDateLabel.text = longDateFormatter.string(for: targetNote?.createdDate)
        modifiedDateLabel.text = longDateFormatter.string(for: targetNote?.modifiedDate)
    }
    
    private func setupPinSwitch() {
        guard let isPinned = isPinned else {
            return
        }
        pinSwitch.isOn = isPinned
    }
    

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
