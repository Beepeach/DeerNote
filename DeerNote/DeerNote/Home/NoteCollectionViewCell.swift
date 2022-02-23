//
//  NoteCollectionViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/31/22.
//

import UIKit

protocol NoteCollectionViewCellDelegate: AnyObject {
    func optionbuttonDidTapped(_ button: UIButton, selectdIndex: Int)
}

class NoteCollectionViewCell: UICollectionViewCell {
    var isAnimating: Bool = true
    var cellColor: (UIColor, UIColor)?
    weak var delegate: NoteCollectionViewCellDelegate?
    
    // MARK: @IBOutlet
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var modifiedDateLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var pinImageView: UIImageView!
    
    // MARK: @IBAction
    @IBAction func tapOptionsButton(_ sender: UIButton) {
        delegate?.optionbuttonDidTapped(sender, selectdIndex: sender.tag)
    }
    
    // MARK: ViewLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setCellShadow()
        setCellCorner()
        contentsLabel.textColor = .white
        optionsButton.tintColor = .white
        pinImageView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradationBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let previousGradientLayer = contentView.layer.sublayers?.first as? CAGradientLayer {
            previousGradientLayer.removeFromSuperlayer()
        }
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
        self.contentView.setGradationBackgroundColor(colors: cellColor ?? GradationColor.blue)
    }
    
    func startShakeAnimation() {
        let shakeAnimation = setupShakeAnimation()
        self.layer.add(shakeAnimation, forKey: "shakeAnimation")
        
        isAnimating = true
    }
    
    private func setupShakeAnimation() -> CABasicAnimation {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 999999
        setupShakeAngle(shakeAnimation)
        return shakeAnimation
    }
    
    private func setupShakeAngle(_ shakeAnimation: CABasicAnimation) {
        let startAngle: Float =  2 * (Float.pi / 180)
        let stopAngle = -startAngle
        shakeAnimation.fromValue = startAngle
        shakeAnimation.toValue = stopAngle
        shakeAnimation.autoreverses = true
    }
    
    func stopShakeAnimation() {
        self.layer.removeAnimation(forKey: "shakeAnimation")
        isAnimating = false
    }
    
    deinit {
        print("cell", #function)
    }
}
