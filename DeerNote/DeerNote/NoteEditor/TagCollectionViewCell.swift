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
    @IBAction func tapTagRemoveButton(_ sender: UIButton) {
        guard let name = tagNameLabel.text else {
            return
        }
        NotificationCenter.default.post(name: .tapRemoveButtonDidTapped, object: nil, userInfo: ["tagName": name])
    }
}


extension Notification.Name {
    static let tapRemoveButtonDidTapped = Notification.Name(rawValue: "tapRemoveButtonDidTapped")
}

extension TagCollectionViewCell {
    static let removedTagNameUserInfoKey: String = "tagName"
}

