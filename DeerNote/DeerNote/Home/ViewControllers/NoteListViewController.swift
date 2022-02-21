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
    
    lazy var fetchedResultsController: NSFetchedResultsController<NoteEntity> = {
        let fetchedResultsController: NSFetchedResultsController<NoteEntity> = NSFetchedResultsController(fetchRequest: NoteManager.shared.fetchRequest(), managedObjectContext: CoreDataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    private var collectionViewEditOperations: [BlockOperation] = []
    private var shouldReloadCollectionView: Bool = false
    private let fetchedResultsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
    
    
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: Fetch에 실패할 경우 에러처리 코드가 들어가야합니다.
            print(#function, print(error.localizedDescription))
        }
    }
    
    private func setdimmingView() {
        dimmingView.alpha = 0.0
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
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
            guard let vc = segue.destination as? NoteEditorViewController else {
                return
            }
            guard let cell = sender as? NoteCollectionViewCell else {
                return
            }
            guard let index = noteListCollectionView.indexPath(for: cell) else {
                return
            }
            let target = fetchedResultsController.object(at: index)
            vc.title = "Edit"
            vc.targetNote = target
            
            vc.contents = target.contents
        default:
            break
        }
    }
    
    // MARK: Deinitializer
    deinit {
        fetchedResultsController.delegate = nil
        fetchedResultsQueue.cancelAllOperations()
        collectionViewEditOperations.removeAll()
    }
}


// MARK: - UICollectionViewDataSource
extension NoteListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionViewCell", for: indexPath) as? NoteCollectionViewCell else {
            return UICollectionViewCell()
        }
        let targetNote = fetchedResultsController.object(at: indexPath)
        
        cell.cellColor = (targetNote.fromColor ?? GradationColor.blue.from, targetNote.toColor ?? GradationColor.blue.to)
        cell.contentsLabel.text = targetNote.contents
        // TODO: - DateLabel을 추가시켜줘야합니다.
        
        startOrStopShakeAnimation(cell)
        
        return cell
    }
    
    private func startOrStopShakeAnimation(_ cell: NoteCollectionViewCell) {
        if isLongPressed {
            cell.startShakeAnimation()
        } else {
            cell.stopShakeAnimation()
        }
    }
}


//MARK: - UICollectionViewDelegate
extension NoteListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("source: \(sourceIndexPath)")
        print("destination: \(destinationIndexPath)")
        // TODO: - fetchedResultsController에서 reordering을 구현하는 방법
//        let note = CoreDataManager.shared.allNotes.remove(at: sourceIndexPath.item)
//        CoreDataManager.shared.allNotes.insert(note, at: destinationIndexPath.item)
    }
    
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


// MARK: - Notification
extension Notification.Name {
    static let noteDidLongPressed = Self(rawValue: "noteDidLongPressed")
}


// MARK: - NSFetchedResultsControllerDelegate
extension NoteListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            
            if noteListCollectionView.numberOfSections > 0 {
                if noteListCollectionView.numberOfItems(inSection: newIndexPath.section) == 0{
                    self.shouldReloadCollectionView = true
                } else {
                    collectionViewEditOperations.append(
                        BlockOperation{ [weak self] in
                            if let strongSelf = self {
                                DispatchQueue.main.async {
                                    strongSelf.noteListCollectionView.insertItems(at: [newIndexPath])
                                }
                            }
                        }
                    )
                }
            } else {
                self.shouldReloadCollectionView = true
            }
            print("Insert Obejct: \(newIndexPath)")
        case .update:
            guard let indexPath = indexPath else {
                return
            }
            
            collectionViewEditOperations.append(
                BlockOperation { [weak self] in
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            strongSelf.noteListCollectionView.reloadItems(at: [indexPath])
                        }
                    }
                    
                }
            )
            print("Updata Object: \(indexPath)")
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else {
                      return
                  }
            
            collectionViewEditOperations.append(
                BlockOperation { [weak self] in
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            strongSelf.noteListCollectionView.moveItem(at: indexPath, to: newIndexPath)
                        }
                    }
                }
            )
            print("Move Object: \(indexPath)")
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            
            if noteListCollectionView.numberOfItems(inSection: indexPath.section) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                collectionViewEditOperations.append(
                    BlockOperation { [weak self] in
                        if let strongSelf = self {
                            strongSelf.noteListCollectionView.deleteItems(at: [indexPath])
                        }
                        
                    }
                )
            }
            print("Delete Object: \(indexPath)")
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if self.shouldReloadCollectionView {
            DispatchQueue.main.async {
                self.noteListCollectionView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.noteListCollectionView.performBatchUpdates {
                    for operation in self.collectionViewEditOperations {
                        self.fetchedResultsQueue.addOperation(operation)
                    }
                } completion: { finished in
                    self.collectionViewEditOperations.removeAll()
                }
            }
        }
        
    }
}
