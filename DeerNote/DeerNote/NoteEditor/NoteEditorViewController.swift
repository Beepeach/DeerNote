//
//  NoteEditorViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/12/22.
//

import UIKit

class NoteEditorViewController: UIViewController {
    // MARK: @IBOutlet
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var EndEditBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tagViewBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: VCLifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: - 나가지면 note를 저장하는 코드를 구현해야합니다.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultApperance()
        adjustApperanceWhenKeyboardShow()
        resetApperanceWhenKeyboardHide()
        
        contentTextView.becomeFirstResponder()
    }
    
    private func setupDefaultApperance() {
        navigationController?.navigationBar.tintColor = .systemTeal
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
    
    private func adjustApperanceWhenKeyboardShow() {
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
    }
    
    private func resetApperanceWhenKeyboardHide() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.tagViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    
    // MARK: @IBAction
    @IBAction func tapEndEditButton(_ sender: UIBarButtonItem) {
        contentTextView.resignFirstResponder()
    }
}
