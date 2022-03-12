//
//  NoticeDetailViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 3/12/22.
//

import UIKit

class NoticeDetailViewController: UIViewController {
    var noticeTitle: String?
    var date: Date?
    var contents: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = noticeTitle
        dateLabel.text = longDateFormatter.string(for: date)
        contentsLabel.text = contents
    }
}
