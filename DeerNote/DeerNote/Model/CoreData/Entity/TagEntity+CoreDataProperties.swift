//
//  TagEntity+CoreDataProperties.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/20/22.
//
//

import Foundation
import CoreData


extension TagEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
        return NSFetchRequest<TagEntity>(entityName: "Tag")
    }

    @NSManaged public var name: String?
    @NSManaged public var notes: NoteEntity?

}

extension TagEntity : Identifiable {

}
