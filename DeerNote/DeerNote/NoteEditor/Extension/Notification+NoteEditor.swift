//
//  Notification.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/24/22.
//

import Foundation

// MARK:  TagCollectionViewCell
extension Notification.Name {
    static let tagRemoveButtonDidTapped = Notification.Name(rawValue: "tapRemoveButtonDidTapped")
}

extension TagCollectionViewCell {
    static let removedTagNameUserInfoKey: String = "tagName"
}
