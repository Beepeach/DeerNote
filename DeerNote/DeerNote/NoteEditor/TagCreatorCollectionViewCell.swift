//
//  TagCreatorCollectionViewCell.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/13/22.
//

import UIKit

protocol TagCreatorCollectionViewCellDelegate: AnyObject {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

class TagCreatorCollectionViewCell: UICollectionViewCell {
    weak var delegate: TagCreatorCollectionViewCellDelegate?
    
    @IBOutlet weak var TagField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TagField.delegate = self
    }
}


// MARK: - UITextFieldDelegate
extension TagCreatorCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            return delegate.textFieldShouldReturn(textField)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = delegate {
            return delegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        
        return true
    }
}
