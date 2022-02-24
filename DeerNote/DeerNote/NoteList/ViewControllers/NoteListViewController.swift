//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit
import CoreData

protocol NoteListViewControllerDelegate: AnyObject {
    func didTapMenuButton(_ vc: NoteListViewController)
    func didTapDimmingView(_ vc: NoteListViewController)
}

class NoteListViewController: UIViewController {
    // MARK: Properties
    private var allNote: [NoteEntity] = []
    weak var delegate: NoteListViewControllerDelegate?
    private var isLongPressed: Bool = false
    private let backgroundSerialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private var notes: [NoteEntity] = []
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var noteListCollectionView: UICollectionView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setdimmingView()
        setupSearchBar()
        setupDoneBarButtonHidden()
        stopShakeAnimationWhenNoEdit()
        
        observeNoteDidRestore()
        observeNoteDidMoveTrash()
        observeNotePinState()
        
        fetchAllNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CoreDataManager.shared.mainContext.hasChanges {
            fetchAllNote()
            noteListCollectionView.reloadData()
        }
    }
    
    private func fetchAllNote() {
        let modifiedDateDSCE = NSSortDescriptor(key: "modifiedDate", ascending: false)
        let customSortIndexASCE = NSSortDescriptor(key: "customSortIndex", ascending: true)
        let request = NoteManager.shared.setupAllNoteFetchRequest(sort: [customSortIndexASCE, modifiedDateDSCE], trash: false)
        guard let allNotes = NoteManager.shared.fetchNotes(with: request) else {
            return
        }
        notes = allNotes
    }
    
    private func setdimmingView() {
        dimmingView.alpha = 0.0
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupDoneBarButtonHidden() {
        doneBarButton.isEnabled = false
        doneBarButton.tintColor = .clear
    }
    
    private func stopShakeAnimationWhenNoEdit() {
        NotificationCenter.default.addObserver(forName: .noteDidLongPressed, object: nil, queue: .main) { [weak self] _ in
            self?.backgroundSerialQueue.schedule(after: .init(Date() + 20), {
                DispatchQueue.main.async {
                    self?.tapDoneButton(UIBarButtonItem())
                }
            })
        }
    }
    
    private func observeNoteDidRestore() {
        NotificationCenter.default.addObserver(forName: .noteDidRestore, object: nil, queue: .main) { _ in
            self.fetchAllNote()
            self.noteListCollectionView.reloadData()
        }
    }
    
    private func observeNotePinState() {
        NotificationCenter.default.addObserver(forName: .notePinButtonDidTapped, object: nil, queue: .main) { _ in
            self.fetchAllNote()
            self.noteListCollectionView.reloadData()
        }
    }
    
    private func observeNoteDidMoveTrash() {
        NotificationCenter.default.addObserver(forName: .noteDidMoveTrash, object: nil, queue: .main) { noti in
            guard let userInfo = noti.userInfo else {
                return
            }
            guard let targetIndex = userInfo[NoteListViewController.selectedNoteIndexUserInfoKey] as? Int else {
                return
            }
            
            self.removeNote(at: targetIndex)
        }
    }
    
    private func removeNote(at targetIndex: Int) {
        self.notes.remove(at: targetIndex)
        self.noteListCollectionView.deleteItems(at: [IndexPath(item: targetIndex, section: 0)])
        
        (targetIndex ..< self.notes.count).forEach {
            self.noteListCollectionView.reloadItems(at: [IndexPath(item: $0, section: 0)])
        }
    }
    
    
    // MARK: @IBAction
    @IBAction func tapMenu(_ sender: UIBarButtonItem) {
        delegate?.didTapMenuButton(self)
        tapDoneButton(UIBarButtonItem())
    }
    
    @IBAction func tapDoneButton(_ sender: UIBarButtonItem) {
        self.isLongPressed = false
        noteListCollectionView.reloadData()
        setupDoneBarButtonHidden()
        backgroundSerialQueue.cancelAllOperations()
        
        CoreDataManager.shared.saveMainContext()
    }
    
    @IBAction func tapDimmingView(_ sender: Any) {
        delegate?.didTapDimmingView(self)
    }
    
    @IBAction func pressNoteListCell(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let selectedIndexPath = noteListCollectionView.indexPathForItem(at: sender.location(in: noteListCollectionView)) else {
                return
            }
            guard let selectedCell = noteListCollectionView.cellForItem(at: selectedIndexPath) as? NoteCollectionViewCell else {
                return
            }
            startShakeAnimationWithVisibleCell(without: selectedCell)
            noteListCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            noteListCollectionView.updateInteractiveMovementTargetPosition(sender.location(in: noteListCollectionView))
        case .ended:
            backgroundSerialQueue.cancelAllOperations()
            noteListCollectionView.endInteractiveMovement()
            
            guard let selectedIndexPath = noteListCollectionView.indexPathForItem(at: sender.location(in: noteListCollectionView)) else {
                resetCellWhenPressEndAmbiguousPosition()
                return
            }
            
            guard let selectedCell = noteListCollectionView.cellForItem(at: selectedIndexPath) as? NoteCollectionViewCell else {
                return
            }
            selectedCell.startShakeAnimation()
            setupTranslucent(with: selectedCell)
            
            isLongPressed = true
            noteListCollectionView.reloadData()
            NotificationCenter.default.post(name: .noteDidLongPressed, object: nil)
        default:
            noteListCollectionView.cancelInteractiveMovement()
        }
    }
    
    private func startShakeAnimationWithVisibleCell(without selectedCell: NoteCollectionViewCell) {
        noteListCollectionView.visibleCells.map { $0 as? NoteCollectionViewCell }.forEach { $0?.startShakeAnimation() }
        
        selectedCell.stopShakeAnimation()
        setupTranslucent(with: selectedCell)
        setupDoneBarButtonVisible()
    }
    
    private func resetCellWhenPressEndAmbiguousPosition() {
        if let visibleCells = noteListCollectionView.visibleCells as? [NoteCollectionViewCell] {
            visibleCells.forEach {
                resetAlpha(cell: $0)
                resetAnimation(cell: $0)
            }
        }
    }
    
    private func resetAlpha(cell: NoteCollectionViewCell) {
        if cell.contentView.alpha != 1.0 {
            cell.contentView.alpha = 1.0
        }
    }
    
    private func resetAnimation(cell: NoteCollectionViewCell) {
        if cell.isAnimating == false {
            cell.startShakeAnimation()
        }
    }
    
    private func setupTranslucent(with selectedCell: NoteCollectionViewCell) {
        UIView.animate(withDuration: 0.3) {
            selectedCell.contentView.alpha = selectedCell.contentView.alpha == 1.0 ? 0.75 : 1.0
        }
    }
    
    private func setupDoneBarButtonVisible() {
        UIView.animate(withDuration: 0.3) {
            self.doneBarButton.isEnabled = true
            self.doneBarButton.tintColor = .systemTeal
        }
    }
    
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEditorVCSegue":
            guard let noteEditorVC = segue.destination as? NoteEditorViewController else {
                return
            }
            guard let cell = sender as? NoteCollectionViewCell else {
                return
            }
            guard let index = noteListCollectionView.indexPath(for: cell) else {
                return
            }
            setupData(noteEditorVC, noteIndex: index)
        default:
            break
        }
    }
    
    private func setupData(_ vc: NoteEditorViewController, noteIndex: IndexPath) {
        let note = notes[noteIndex.item]
        vc.title = "Edit"
        vc.targetNote = note
        vc.contents = note.contents
    }
}


// MARK: - UICollectionViewDataSource
extension NoteListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionViewCell", for: indexPath) as? NoteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        setupCell(cell, at: indexPath)
        startOrStopShakeAnimation(cell)
        
        return cell
    }
    
    private func setupCell(_ cell: NoteCollectionViewCell, at indexPath: IndexPath) {
        let targetNote = notes[indexPath.item]
        
        cell.cellColor = (targetNote.fromColor ?? GradationColor.blue.from, targetNote.toColor ?? GradationColor.blue.to)
        
        cell.contentsLabel.text = targetNote.contents
        cell.modifiedDateLabel.text = shortDateFormatter.string(for: targetNote.modifiedDate)
        
        cell.optionsButton.tag = indexPath.item
        cell.optionsButton.isEnabled = !isLongPressed
        
        cell.pinImageView.isHidden = targetNote.customSortIndex < 0 ? false : true
    }
    
    private func startOrStopShakeAnimation(_ cell: NoteCollectionViewCell) {
        if isLongPressed {
            cell.startShakeAnimation()
        } else {
            cell.stopShakeAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        updateData(remove: sourceIndexPath, insert: destinationIndexPath)
        updateCustomSortIndex()
    }
    
    private func updateData(remove source: IndexPath, insert destination: IndexPath) {
        let note = notes.remove(at: source.item)
        notes.insert(note, at: destination.item)
    }
    
    private func updateCustomSortIndex() {
        var count: Int = 0
        
        notes.forEach {
            NoteManager.shared.updateWithNoSave($0, sortIndex: count)
            count += 1
        }
    }
}


// MARK: - UICollectionViewDelegate
extension NoteListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if self.isLongPressed == true {
            return false
        }
        
        return true
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension NoteListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let itemWidth = calculateItemWidth(flowLayout, columns: 2)
        let itemHeight = calculateItemHight(flowLayout, rows: 6)
        
        return CGSize(width: itemWidth.rounded(.down), height: itemHeight.rounded(.down))
    }
    
    private func calculateItemWidth(_ layout: UICollectionViewFlowLayout, columns: Int) -> CGFloat {
        let leftInset: CGFloat = layout.sectionInset.left
        let rightInset: CGFloat = layout.sectionInset.right
        let itemInset: CGFloat = layout.minimumInteritemSpacing
        let safeAreaInset: CGFloat = view.safeAreaInsets.left + view.safeAreaInsets.right
        let totalHorizonInset: CGFloat = leftInset + rightInset + (itemInset * CGFloat(columns)) + safeAreaInset
        let contentsWidth: CGFloat = view.frame.width - totalHorizonInset
        
        let itemWidth: CGFloat = contentsWidth / CGFloat(columns)
        
        return itemWidth
    }
    
    private func calculateItemHight(_ layout: UICollectionViewFlowLayout, rows: Int) -> CGFloat {
        // TODO: SearchController로 인해 layer가 깨지는 문제가 발생해서 CollectionView의 yOffset은 삭제 이후 문제가 해결되면 다시 추가 예정
        let topInset: CGFloat = layout.sectionInset.top
        let bottomInset: CGFloat = layout.sectionInset.bottom
        let lineInset: CGFloat = layout.minimumLineSpacing
        let totalVerticalInset: CGFloat = topInset + bottomInset + lineInset
        let contentsHeight: CGFloat = view.frame.height - totalVerticalInset
        
        let itemHeight: CGFloat = contentsHeight / CGFloat(rows)
        
        return max(itemHeight, 100)
    }
}


// MARK: - NoteCollectionViewDeleagte
extension NoteListViewController: NoteCollectionViewCellDelegate {
    func optionbuttonDidTapped(_ button: UIButton, selectedIndex: Int) {
        guard let popoverVC = storyboard?.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController else {
            return
        }
        setupVC(popoverVC, source: button)
        setupVCData(popoverVC, at: selectedIndex, source: button)
        present(popoverVC, animated: true, completion: nil)
        print(selectedIndex)
    }
    private func setupVC(_ popoverVC: PopoverViewController, source: UIButton) {
        popoverVC.modalPresentationStyle = .popover
        popoverVC.popoverPresentationController?.sourceView = source
        popoverVC.popoverPresentationController?.delegate = self
    }
    
    private func setupVCData(_ popoverVC: PopoverViewController, at selectedIndex: Int, source: UIButton) {
        let targetNote = notes[selectedIndex]
        popoverVC.targetNote = targetNote
        popoverVC.index = source.tag
        popoverVC.isPinned = targetNote.customSortIndex < 0 ? true : false
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension NoteListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
