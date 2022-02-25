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
    var tags: [Tag] = []
    var tagEntities: Set<TagEntity> = []
    var contents: String?
    var targetNote: NoteEntity?
    var isTagChanged: Bool = false
    
    // MARK: @IBOutlet
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var noteInfoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var endEditBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tagViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    // MARK: @IBAction
    @IBAction func tapEndEditButton(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteInfoVC = segue.destination as? NoteInfoTableViewController else {
            return
        }
        guard let targetNote = targetNote else {
            return
        }
        noteInfoVC.targetNote = targetNote
    }
    
    // MARK: VCLifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        guard let contents = contentTextView.text, contents.count > 0 else {
            return
        }
        
        tags.forEach {
            TagManager.shared.createNewTags(name: $0.name)
        }
        
        upsertNote(contents: contents)
    }
    
    private func upsertNote(contents: String) {
        if let targetNote = targetNote {
            NoteManager.shared.update(targetNote, contents: contents, tags: tags, isChanged: isTagChanged)
        } else {
            NoteManager.shared.addNote(contents: contents, tags: tags)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultApperance()
        adjustApperanceWhenKeyboardShow()
        resetApperanceWhenKeyboardHide()
        observeTagRemoveButtonTapped()
    }
    
    private func setupDefaultApperance() {
        navigationController?.navigationBar.tintColor = .systemTeal
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        if let targetNote = targetNote {
            contentTextView.text = contents
            guard let entities = targetNote.tags as? Set<TagEntity> else {
                return
            }
            tagEntities = entities
            tags = tagEntities.map { Tag(name: $0.name ?? "") }.sorted { $0.name < $1.name }
        } else {
            contentTextView.text = nil
            contentTextView.becomeFirstResponder()
            hideNoteInfoButton()
        }
    }
    
    private func hideNoteInfoButton() {
        noteInfoBarButtonItem.isEnabled = false
        noteInfoBarButtonItem.tintColor = .clear
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
        NotificationCenter.default.addObserver(forName: .tagRemoveButtonDidTapped, object: nil, queue: .main) { [weak self] noti in
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
            
            if let targetNote = self?.targetNote {
                guard let targetTagEntity = self?.tagEntities.first(where: { tagEntity in
                    tagEntity.name == targetTag
                }) else { return }
                targetNote.removeFromTags(targetTagEntity)
                targetTagEntity.removeFromNotes(targetNote)
                self?.isTagChanged = true
                print("remove relation \(targetNote.contents ?? "") \(targetTagEntity.name ?? "")")
            }
        }
    }
    
    private func removeTag(at targetIndex : Int) {
        self.tags.remove(at: targetIndex)
        self.tagCollectionView.deleteItems(at: [IndexPath(item: targetIndex, section: 1)])
    }
    
    // MARK: Deinitializer
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function)
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
            
            if let _ = targetNote {
                cell.isEditMode = true
            }
            
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
        
        if tags.contains(where: { $0.name == text }) {
            textField.text = nil
            return false
        }
        
        tags.append(Tag(name: text))
        textField.text = nil
        textField.becomeFirstResponder()
        tagCollectionView.reloadSections(IndexSet(integer: 1))
        
        if let _ = targetNote {
            isTagChanged = true
        }
        
        return true
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



