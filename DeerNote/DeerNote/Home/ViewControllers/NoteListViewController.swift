//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

protocol NoteListViewControllerDelegate: AnyObject {
    func didTapMenuButton(_ vc: NoteListViewController)
    func didTapDimmingView(_ vc: NoteListViewController)
}

extension Notification.Name {
    static let noteDidLongPressed = Self(rawValue: "noteDidLongPressed")
}

class NoteListViewController: UIViewController {
    // MARK: Properties
    var dummyNote: [Note] = [
        Note(contents: "1", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "2", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "3", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "4", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "5", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "6", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "7", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: """
             반가워요
             이걸 어디서 끊어야할까요
             """, tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "잘있어요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "더미더미", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "미더미더", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "크하하하하", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "안녕하세요. 반갑습니다 글자를 어디서부터 끊어야할지 잘 모르겠네요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: """
             반가워요
             이걸 어디서 끊어야할까요
             """, tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "잘있어요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "더미더미", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "미더미더", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
        Note(contents: "크하하하하", tag: [], date: Date(), updatedDate: Date(), isDeleted: false)
    ]
    weak var delegate: NoteListViewControllerDelegate?
    var isLongPressed: Bool = false
    let backgroundQueue = OperationQueue()
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var noteListCollectionView: UICollectionView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setdimmingView()
        setupSearchBar()
        
        doneBarButton.isEnabled = false
        doneBarButton.tintColor = .clear
        
        NotificationCenter.default.addObserver(forName: .noteDidLongPressed, object: nil, queue: .main) { [weak self] _ in
            // TODO: - Operation을 계속 생성하는데 만약 시간을 reset하는 다른 방법이 있다면 변경하는게 좋습니다.
            let noteEditingStopOperation = BlockOperation {
                autoreleasepool {
                }
            }
            
            noteEditingStopOperation.addExecutionBlock {
                autoreleasepool {
                    // TODO: - sleep말고 다른 좋은 방법이 있다면 변경하는게 좋습니다.
                    sleep(20)
                    guard !noteEditingStopOperation.isCancelled else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tapDoneButton(UIBarButtonItem())
                    }
                }
            }
            
            self?.backgroundQueue.addOperation(noteEditingStopOperation)
        }
        
    }
    
    private func setdimmingView() {
        dimmingView.alpha = 0.0
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
    }
    
    // MARK: @IBAction
    @IBAction func tapMenu(_ sender: UIBarButtonItem) {
        delegate?.didTapMenuButton(self)
    }
    @IBAction func tapDoneButton(_ sender: UIBarButtonItem) {
        self.isLongPressed = false
        noteListCollectionView.reloadData()
        doneBarButton.isEnabled = false
        doneBarButton.tintColor = .clear
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
            
            noteListCollectionView.visibleCells.map { $0 as? NoteCollectionViewCell }.forEach { $0?.startShakeAnimation() }
            
            selectedCell.stopShakeAnimation()
            UIView.animate(withDuration: 0.3) {
                selectedCell.contentView.alpha = 0.75
            }
            
            UIView.animate(withDuration: 0.3) {
                self.doneBarButton.isEnabled = true
                self.doneBarButton.tintColor = .systemTeal
                
            }
            
            noteListCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            noteListCollectionView.updateInteractiveMovementTargetPosition(sender.location(in: noteListCollectionView))
        case .ended:
            backgroundQueue.cancelAllOperations()
            
            noteListCollectionView.endInteractiveMovement()
            guard let selectedIndexPath = noteListCollectionView.indexPathForItem(at: sender.location(in: noteListCollectionView)) else {
                return
            }
            
            guard let selectedCell = noteListCollectionView.cellForItem(at: selectedIndexPath) as? NoteCollectionViewCell else {
                return
            }
            selectedCell.startShakeAnimation()
            UIView.animate(withDuration: 0.3) {
                selectedCell.contentView.alpha = 1.0
            }
            isLongPressed = true
            noteListCollectionView.reloadData()
            
            NotificationCenter.default.post(name: .noteDidLongPressed, object: nil)
        default:
            noteListCollectionView.cancelInteractiveMovement()
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEditorVCSegue":
            let vc = segue.destination as! NoteEditorViewController
            vc.title = "Edit"
            
            guard let cell = sender as? NoteCollectionViewCell else {
                return
            }
            
            guard let targetIndexPath = noteListCollectionView.indexPath(for: cell) else {
                return
            }
            
            vc.contents = cell.contentsLabel.text
            
            
        default:
            break
        }
    }
}


// MARK: - UICollectionViewDataSource
extension NoteListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyNote.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionViewCell", for: indexPath) as? NoteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.cellColor = dummyNote[indexPath.item].color
        cell.contentsLabel.text = dummyNote[indexPath.item].contents
        
        if isLongPressed {
            cell.startShakeAnimation()
        } else {
            cell.stopShakeAnimation()
        }
        
        return cell
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
        let note = dummyNote.remove(at: sourceIndexPath.item)
        dummyNote.insert(note, at: destinationIndexPath.item)
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
