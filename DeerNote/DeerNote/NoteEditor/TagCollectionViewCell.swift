//
//  TagCollectionViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/13/22.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var tagremoveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.cornerRadius = 3
    }
}



