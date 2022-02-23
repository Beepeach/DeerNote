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
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLables()
        setupPinSwitch()
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
}
