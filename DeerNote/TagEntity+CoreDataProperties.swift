//
//  TagEntity+CoreDataProperties.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/26/22.
//
//

import Foundation
import CoreData


extension TagEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
        return NSFetchRequest<TagEntity>(entityName: "Tag")
    }

    @NSManaged public var name: String?
    @NSManaged public var customSortIndex: Int64
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension TagEntity {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: NoteEntity)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: NoteEntity)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension TagEntity : Identifiable {

}
