//
//  UIViewController+DateFormatter.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/24/22.
//

import Foundation
import UIKit

extension UIViewController {
    var shortDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        
        return dateFormatter
    }
    
    var longDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd  HH:mm:ss"
        
        return formatter
    }
}
