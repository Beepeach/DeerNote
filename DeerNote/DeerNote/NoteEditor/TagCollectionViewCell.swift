//
//  TagCollectionViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/13/22.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    // MARK: @IBOutlet
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var tagRemoveButton: UIButton!
    
    // MARK: @IBAction
    @IBAction func tapTagRemoveButton(_ sender: UIButton) {
        guard let name = tagNameLabel.text else {
            return
        }
        NotificationCenter.default.post(name: .tagRemoveButtonDidTapped, object: nil, userInfo: ["tagName": name])
    }
    
    // MARK: ViewLayout
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.cornerRadius = 3
    }
}
