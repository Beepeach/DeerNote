//
//  SortOptionTableViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/28/22.
//

import UIKit

class SortOptionTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
