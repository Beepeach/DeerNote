//
//  ColorTransformer.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/19/22.
//

import Foundation
import UIKit

@objc(ColorTransformer)
final class ColorTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else {
            return nil
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform UIColor to Data")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
            
            return color
        } catch {
            assertionFailure("Failed to transform Data to UIColor")
            return nil
        }
    }
}


// TODO: - Appdelegate에서 init을 호출하고 등록해야하는데 등록 안해도 사용이 가능합니다? 자세히 알아보고 필요없을시 해당 코드를 삭제하세요.
extension ColorTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ColorTransformer.self))
    
    static func register() {
        let transformer = ColorTransformer()
        setValueTransformer(transformer, forName: name)
    }
}
