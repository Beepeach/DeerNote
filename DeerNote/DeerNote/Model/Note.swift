//
//  Note.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/31/22.
//

import Foundation
import UIKit

struct Note {
    var contents: String
    var tag: [Tag]
    let date: Date
    let updatedDate: Date
    var isDeleted: Bool
    var color: (UIColor, UIColor) = GradationColor.shared.getRandomColor()
}

extension Note {
    init() {
        contents = ""
        tag = [Tag()]
        date = Date()
        updatedDate = date
        isDeleted = false
        color = GradationColor.shared.getRandomColor()
    }
}
