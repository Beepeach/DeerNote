//
//  DeletedNoteTableViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/14/22.
//

import UIKit

class DeletedNoteTableViewCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var deletedDdayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
