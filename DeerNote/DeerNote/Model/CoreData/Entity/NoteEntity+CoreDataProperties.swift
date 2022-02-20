//
//  NoteEntity+CoreDataProperties.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/20/22.
//
//

import UIKit
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "Note")
    }

    @NSManaged public var contents: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var fromColor: UIColor?
    @NSManaged public var isDeletedNote: Bool
    @NSManaged public var toColor: UIColor?
    @NSManaged public var modifiedDate: Date?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension NoteEntity {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension NoteEntity : Identifiable {

}
