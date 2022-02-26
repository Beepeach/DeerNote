//
//  NotificationName.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/24/22.
//

import Foundation

// MARK: - NoteListViewController
extension Notification.Name {
    static let noteDidLongPressed = Self(rawValue: "noteDidLongPressed")
}


// MARK: - PopoverViewController
extension Notification.Name {
    static let noteDidMoveTrash = Notification.Name("noteDidMoveTrash")
    static let notePinButtonDidTapped = Notification.Name("noteDidPinned")
}

extension PopoverViewController {
    static let selectedNoteIDUserInfoKey: String = "id"
}


// MARK: - ContainerViewController
extension Notification.Name {
    static let tagNoteVCWillReplaced = Notification.Name(rawValue: "tagNoteVCWillReplaced")
    static let sideMenuDidClosed = Notification.Name(rawValue: "sideMenuDidClosed")
}
