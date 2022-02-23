//
//  UINavigationController + shouldAutoroate.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/7/22.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        
        return super.shouldAutorotate
    }
}
