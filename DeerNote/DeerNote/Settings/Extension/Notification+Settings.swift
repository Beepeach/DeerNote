//
//  Notification+Settings.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/28/22.
//

import Foundation

// MARK: - NoteSortTableViewController
extension Notification.Name {
    static let noteSortMenuWillDisappear = Notification.Name("noteSortMenuWillDisappear")
}

extension NoteSortTableViewController {
    static let noteSortUserInfoKey = "noteSort"
    static let noteOrderUserInfoKey = "noteOrder"
}


// MARK: - TagSortTableViewController
extension Notification.Name {
    static let tagSortMenuWillDisappear = Notification.Name("tagSortMenuWillDisappear")
}

extension TagSortTableViewController {
    static let tagSortUserInfoKey = "tagSort"
    static let tagOrderUserInfoKey = "tagOrder"
}
