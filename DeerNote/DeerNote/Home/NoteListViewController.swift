//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

protocol NoteListViewControllerDelegate: AnyObject {
    func didTapMenuButton(_ vc: NoteListViewController)
}

class NoteListViewController: UIViewController {
    // MARK: Properties
    var dummyNote: [Note] = [
        Note(contents: "안녕하세요. 반갑습니다 글자를 어디서부터 끊어야할지 잘 모르겠네요", tag: [], date: Date(), updatedDate: Date(), isDeleted: false),
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
    private var isSlideMenuAppeared: Bool = false
    private var touchBeginPoint: CGFloat = 0.0
    private var differenceFromTouchBeginPoint: CGFloat = 0.0
    private var menuVCWidth: CGFloat {
        return view.frame.width * 0.8
    }
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var noteListCollectionView: UICollectionView!
    
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenuVCHiding()
        setupSearchBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.delegate = self
        }
    }
    
    private func setMenuVCHiding() {
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
    }
    
    // MARK: @IBAction
    @IBAction func tapMenu(_ sender: UIBarButtonItem) {
        delegate?.didTapMenuButton(self)
    }
    
    // MARK: Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isSlideMenuAppeared {
            guard let touch = touches.first else {
                return
            }
            saveTouchBeginPoint(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isSlideMenuAppeared {
//            guard let touch = touches.first else {
//                return
//            }
//            
//            let difference = calculateDifferenceFromTouchBeginPoint(touch)
//            moveMenuVC(difference)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isSlideMenuAppeared {
            guard let _ = touches.first else {
                return
            }
            
            completeMenuVCMove()
        }
    }
    
    private func saveTouchBeginPoint(_ touch: UITouch) {
//        let location = touch.location(in: dimmingView)
//        touchBeginPoint = location.x
    }
    
//    private func calculateDifferenceFromTouchBeginPoint(_ touch: UITouch) -> CGFloat {
//        let location = touch.location(in: dimmingView)
//        let differenceFromTouchBeginPointOfX = touchBeginPoint - location.x
//
//        return differenceFromTouchBeginPointOfX
//    }
    
    private func moveMenuVC(_ difference: CGFloat) {
        if difference > 0 && difference < menuVCWidth {
//            menuContainerViewLeadingConstraint.constant = -difference
            differenceFromTouchBeginPoint = difference
            transluentBackView(difference)
        }
    }
    
    private func transluentBackView (_ difference: CGFloat) {
//        dimmingView.alpha = 0.75 - (0.75 * (difference / menuVCWidth))
        navigationController?.navigationBar.alpha = 0.01 + (1.0 * max(0, difference - menuVCWidth * 0.8) / (menuVCWidth * 0.2))
    }
    
    private func completeMenuVCMove() {
        if differenceFromTouchBeginPoint > menuVCWidth / 4 {
            UIView.animate(withDuration: 0.3) {
//                self.disappearSlideMenu()
                self.navigationController?.navigationBar.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            
        } else {
            UIView.animate(withDuration: 0.3) {
//                self.appearSlideMenu()
                self.navigationController?.navigationBar.alpha = 0.01
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - CustomMethods
    override var shouldAutorotate: Bool {
        if isSlideMenuAppeared {
            return false
        }
        
        return true
    }
}


// MARK: - MenuViewControllerDelegate
extension NoteListViewController: MenuViewControllerDeleagete {
    func buttonDidTapped(_ vc: UIViewController) {
        UIView.animate(withDuration: 0.3) {
//            self.disappearSlideMenu()
            self.view.layoutIfNeeded()
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
        
        cell.contents.text = dummyNote[indexPath.item].contents
        
        return cell
    }
}


//MARK: - UICollectionViewDelegate
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
