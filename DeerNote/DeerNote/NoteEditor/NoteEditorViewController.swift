//
//  NoteEditorViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/12/22.
//

import UIKit
import CoreData

class NoteEditorViewController: UIViewController {
    // MARK: Properties
    var tags: [Tag] = [
    ]
    
    var contents: String?
    var targetNote: NoteEntity?
    
    // MARK: @IBOutlet
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var endEditBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tagViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagCollectionView: UICollectionView!

    
    // MARK: VCLifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: - Tag를 추가하는 코드가 들어가야합니다.
        guard let contents = contentTextView.text, contents.count > 0 else {
            return
        }

        if let targetNote = targetNote {
            NoteManager.shared.update(targetNote, contents: contents)
        } else {
            NoteManager.shared.addNote(contents: contents)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultApperance()
        adjustApperanceWhenKeyboardShow()
        resetApperanceWhenKeyboardHide()
        observeTagRemoveButtonTapped()
        contentTextView.becomeFirstResponder()
        
        contentTextView.text = contents
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function)
    }
        
    private func setupDefaultApperance() {
        navigationController?.navigationBar.tintColor = .systemTeal
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
    
    private func adjustApperanceWhenKeyboardShow() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] noti in
            guard let userInfo = noti.userInfo else {
                return
            }
            
            guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                guard let safeAreaBottomInset = self?.view.safeAreaInsets.bottom else {
                    return
                }
                self?.tagViewBottomConstraint.constant = keyboardSize.height - safeAreaBottomInset
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    private func resetApperanceWhenKeyboardHide() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.tagViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    private func observeTagRemoveButtonTapped() {
        NotificationCenter.default.addObserver(forName: .tapRemoveButtonDidTapped, object: nil, queue: .main) { [weak self] noti in
            guard let userInfo = noti.userInfo else {
                return
            }
            guard let targetTag: String = userInfo[TagCollectionViewCell.removedTagNameUserInfoKey] as? String else {
                return
            }
            guard let targetIndex = self?.tags.firstIndex(where: {$0.name == targetTag}) else {
                return
            }
            
            self?.removeTag(at: targetIndex)
            self?.tagCollectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    private func removeTag(at targetIndex : Int) {
        self.tags.remove(at: targetIndex)
        self.tagCollectionView.deleteItems(at: [IndexPath(item: targetIndex, section: 1)])
    }
    
    
    // MARK: @IBAction
    @IBAction func tapEndEditButton(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}


// MARK: - UICollectionViewDataSource
extension NoteEditorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCreatorCell", for: indexPath) as? TagCreatorCollectionViewCell else {
                return TagCreatorCollectionViewCell()
            }
            cell.delegate = self
            
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.tagNameLabel.text = tags[indexPath.item].name
            
            return cell
        }
    }
}


// MARK: - TagCreatorCollectionViewCellDelegate
extension NoteEditorViewController: TagCreatorCollectionViewCellDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.count > 0 else {
                  return false
        }
        guard !isExistingTag(name: text) else {
            return false
        }
        
        tags.append(Tag(name: text))
        
        textField.text = nil
        textField.becomeFirstResponder()
      
        tagCollectionView.reloadSections(IndexSet(integer: 1))
        return true
    }
    
    private func isExistingTag(name: String) -> Bool {
        if tags.contains(where: { $0.name == name }) {
            return true
        }
        
        return false
    }
    
    // TODO: - 왜 크기가 안바뀔까?? 다이나믹하게 바뀌도록 만들어야합니다.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /*
        if textField.text != nil {
            guard let text = textField.text else {
                return true
            }
            
            let nsText = text as NSString
            let finalString = nsText.replacingCharacters(in: range, with: string)
            textField.frame.size.width = getWidth(text: finalString)
            self.view.layoutIfNeeded()
        }
        */
        
        return true
    }

    private func getWidth(text: String) -> CGFloat {
        let dummyTextField = UITextField(frame: .zero)
        dummyTextField.text = text
        dummyTextField.sizeToFit()
        return dummyTextField.frame.size.width
    }
}



