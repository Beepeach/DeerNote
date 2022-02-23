//
//  MockNoteManager.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/23/22.
//

import Foundation
import CoreData
@testable import DeerNote

class MockNoteManager: NoteManager {
    override var coredataManager: CoreDataManager {
        get {
            return MockCoreDataManager()
        }
        set {
            self.coredataManager = newValue
        }
    }
}
