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
    private var notes: [NoteEntity] = []
    
    private var filteredNotes: [NoteEntity] = []
    private let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    weak var delegate: NoteListViewControllerDelegate?
    private var isLongPressed: Bool = false
    var pressStartLocation: CGPoint?
    private let backgroundSerialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    var tag: TagEntity?
    var isTagVC: Bool = false
    
    // MARK: @IBOutlet
    @IBOutlet weak var noteListCollectionView: UICollectionView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setdimmingView()
        setupSearchController()
        setupDoneBarButtonHidden()
        stopShakeAnimationWhenNoEdit()
        
        observeNoteDidRestore()
        observeNoteDidMoveTrash()
        observeNotePinState()
        observeNoteVCWillReplaced()
        observeSideMenuOnOff()
        observeNoteSortMenuWillDisappear()
        
        fetchAppropriateNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CoreDataManager.shared.mainContext.hasChanges {
            fetchAppropriateNote()
            noteListCollectionView.reloadData()
        }
    }
    
    private func fetchAppropriateNote() {
        let sortDescriptors = setupUserAppropriateSortDescriptors()
        let request = NoteManager.shared.setupAllNoteFetchRequest(sort: sortDescriptors, trash: false)
        guard let allNotes = NoteManager.shared.fetchNotes(with: request) else {
            return
        }
        
        if isTagVC == false {
            notes = allNotes
        } else if let tag = tag, isTagVC == true {
            // Tag Note
            notes = allNotes.filter {
                guard let tags = $0.tags as? Set<TagEntity> else {
                    return false
                }
                return tags.contains(tag)
            }
        } else if tag == nil, isTagVC == true {
            // untagged
            notes = allNotes.filter { $0.tags?.count == 0 }
        }
    }
    
    private func setupUserAppropriateSortDescriptors() -> [NSSortDescriptor] {
        var userSelectedSort: String = Sort.modifiedDate.rawValue
        var userSelectedOrder: Bool = Bool(Sort.descending.rawValue) ?? false
        
        if let sort = UserDefaults.standard.string(forKey: NoteSortTableViewController.noteSortUserInfoKey),
           let order = UserDefaults.standard.string(forKey: NoteSortTableViewController.noteOrderUserInfoKey) {
            userSelectedSort = sort
            userSelectedOrder = Bool(order) ?? false
        }
        
        let pinnedDateDSCE = NSSortDescriptor(key: "pinnedDate", ascending: false)
        let customSortIndexASCE = NSSortDescriptor(key: "customSortIndex", ascending: true)
        let userSelectSort = NSSortDescriptor(key: userSelectedSort, ascending: userSelectedOrder)
        
        return [pinnedDateDSCE, customSortIndexASCE, userSelectSort]
    }
    
    private func setdimmingView() {
        dimmingView.alpha = 0.0
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = "노트를 검색하세요."
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        searchController.definesPresentationContext = true
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
            self.fetchAppropriateNote()
            self.noteListCollectionView.reloadData()
        }
    }
    
    private func observeNotePinState() {
        NotificationCenter.default.addObserver(forName: .notePinButtonDidTapped, object: nil, queue: .main) { _ in
            self.fetchAppropriateNote()
            self.noteListCollectionView.reloadData()
        }
    }
    
    private func observeNoteDidMoveTrash() {
        NotificationCenter.default.addObserver(forName: .noteDidMoveTrash, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo else {
                return
            }
            guard let targetNoteID = userInfo["id"] as? NSManagedObjectID else {
                return
            }
            guard let targetNote = self.notes.filter({ note in
                note.objectID == targetNoteID
            }).first else {
                return
            }
            guard let targetIndex = self.notes.firstIndex(of: targetNote) else {
                return
            }

            self.removeNoteFromList(at: targetIndex)
            self.reloadAfterRemovedCell(after: targetIndex)
        }
    }
    
    private func removeNoteFromList(at index: Int) {
        self.notes.remove(at: index)
        self.noteListCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    private func reloadAfterRemovedCell(after deletedIndex : Int) {
        (deletedIndex ..< self.notes.count).forEach {
            self.noteListCollectionView.reloadItems(at: [IndexPath(item: $0, section: 0)])
        }
    }
    
    private func observeSideMenuOnOff() {
        NotificationCenter.default.addObserver(forName: .sideMenuDidOpend, object: nil, queue: .main) { [weak self] _ in
            self?.searchController.searchBar.isUserInteractionEnabled = false
        }
        
        NotificationCenter.default.addObserver(forName: .sideMenuDidClosed, object: nil, queue: .main) { [weak self] _ in
            self?.searchController.searchBar.isUserInteractionEnabled = true
        }
    }
    
    private func observeNoteVCWillReplaced() {
        NotificationCenter.default.addObserver(forName: .tagNoteVCWillReplaced, object: nil, queue: .main) { [weak self] _ in
            self?.fetchAppropriateNote()
            self?.noteListCollectionView.reloadData()
        }
    }
    
    private func observeNoteSortMenuWillDisappear() {
        NotificationCenter.default.addObserver(forName: .noteSortMenuWillDisappear, object: nil, queue: .main) { _ in
            self.fetchAppropriateNote()
            self.resetCustomSortIndex()
            self.noteListCollectionView.reloadData()
        }
    }
    
    private func resetCustomSortIndex() {
        notes.forEach {$0.customSortIndex = 0}
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
            pressStartLocation = sender.location(in: noteListCollectionView)
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
            
            guard let _ = noteListCollectionView.indexPathForItem(at: pressStartLocation ?? .zero) else {
                return
            }
            
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
        selectedCell.optionsButton.isEnabled = false
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
        guard let _ = noteListCollectionView.indexPathForItem(at: pressStartLocation ?? .zero) else {
            return
        }
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
        let note: NoteEntity
        if isFiltering {
            note = filteredNotes[noteIndex.item]
        } else {
            note = notes[noteIndex.item]
        }
        vc.title = "Edit"
        vc.targetNote = note
        vc.contents = note.contents
    }
}


// MARK: - UICollectionViewDataSource
extension NoteListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNotes.count
        }
        
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
        let targetNote: NoteEntity
        if isFiltering {
            targetNote = filteredNotes[indexPath.item]
        } else {
            targetNote = notes[indexPath.item]
        }
        
        cell.cellColor = GradationColor(from: targetNote.fromColor ?? GradationColor().from, to: targetNote.toColor ?? GradationColor().to)
        
        cell.contentsLabel.text = targetNote.contents
        cell.modifiedDateLabel.text = shortDateFormatter.string(for: targetNote.modifiedDate)
        
        cell.optionsButton.tag = indexPath.item
        cell.pinImageView.isHidden = targetNote.pinnedDate == nil ? true : false
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
        removePin(in: note)
    }
    
    private func removePin(in note: NoteEntity) {
        guard let _ = note.pinnedDate else {
            return
        }
        note.pinnedDate = nil
    }
    
    private func updateCustomSortIndex() {
        for (index, note) in notes.enumerated() {
            NoteManager.shared.updateWithNoSave(note, sortIndex: index)
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
    func optionsbuttonDidTapped(_ button: UIButton, selectedIndex: Int) {
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
        popoverVC.isPinned = targetNote.pinnedDate == nil ? false : true
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension NoteListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


extension NoteListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        dump(searchController.searchBar.text)
        guard let inputText = searchController.searchBar.text?.lowercased() else {
            return
        }
        filteredNotes = notes.filter { $0.contents?.lowercased().contains(inputText) ?? false }
        dump(filteredNotes)
        
        noteListCollectionView.reloadData()
    }
}
