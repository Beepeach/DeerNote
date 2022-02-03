//
//  UIView+setGradationBackgroundColor.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/3/22.
//

import UIKit

extension UIView {
    func setGradationBackgroundColor(colors: (from: UIColor, to: UIColor)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [colors.from.cgColor, colors.to.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
