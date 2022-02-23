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


// MARK: PopoverViewController
extension Notification.Name {
    static let mainContextDidChange = Notification.Name("mainContextDidChange")
    static let notePinButtonDidTapped = Notification.Name("noteDidPinned")
}

extension NoteListViewController {
    static let selectedNoteIndexUserInfoKey: String = "index"
}
