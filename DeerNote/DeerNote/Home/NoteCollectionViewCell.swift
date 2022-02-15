//
//  NoteCollectionViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/31/22.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    var isAnimating: Bool = true
    
    // MARK: @IBOutlet
    @IBOutlet weak var contentsLabel: UILabel!
    
    // MARK: ViewLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setCellShadow()
        setCellCorner()
        contentsLabel.textColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradationBackgroundColor()
    }
    
    private func setCellShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 100, height: 100)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 0.5
    }
    
    private func setCellCorner() {
        self.layer.cornerRadius = 12
    }
    
    func setGradationBackgroundColor() {
        let color = GradationColors().getRandomColor()
        self.contentView.setGradationBackgroundColor(colors: color)
    }
    
    func startShakeAnimation() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 100
        shakeAnimation.autoreverses = true
        
        let startAngle: Float =  2 * (Float.pi / 180)
        let stopAngle = -startAngle
        shakeAnimation.fromValue = startAngle
        shakeAnimation.toValue = stopAngle
        
        self.layer.add(shakeAnimation, forKey: "shakeAnimation")
        
        isAnimating = true
    }
    
    func stopShakeAnimation() {
        self.layer.removeAnimation(forKey: "shakeAnimation")
        isAnimating = false
    }
    
    deinit {
        print(#function)
    }
}
