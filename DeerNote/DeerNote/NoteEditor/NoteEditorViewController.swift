//
//  NoteEditorViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/12/22.
//

import UIKit

class NoteEditorViewController: UIViewController {
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var EndEditBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tagViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .systemTeal
        
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
                                    
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { noti in
            guard let userInfo = noti.userInfo else {
                return
            }
            
            guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let safeAreaBottomInset = self?.view.safeAreaInsets.bottom else {
                    return
                }
                self?.tagViewBottomConstraint.constant = keyboardSize.height - safeAreaBottomInset
                self?.view.layoutIfNeeded()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.tagViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
        }
        
        contentTextView.becomeFirstResponder()
    }
    
    @IBAction func tapEndEditButton(_ sender: UIBarButtonItem) {
        contentTextView.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
    }
}
