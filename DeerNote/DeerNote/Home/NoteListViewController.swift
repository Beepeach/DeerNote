//
//  NoteListViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 1/30/22.
//

import UIKit

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
    ]
    
    
    // MARK: @IBOutlet
    @IBOutlet weak var settingVCLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteListCollectionView: UICollectionView!
    
    // MARK: @IBAction
    @IBAction func tapMenu(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3) {
            self.settingVCLeadingConstraint.constant = self.settingVCLeadingConstraint.constant == 0 ? -self.view.frame.width * 0.8 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenuVCHiding()
        setupSearchBar()
    }
    
    private func setMenuVCHiding() {
        self.settingVCLeadingConstraint.constant = -self.view.frame.width * 0.8
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBar
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
        let totalHorizonInset: CGFloat = leftInset + rightInset + (itemInset * CGFloat(columns))
        let contentsWidth: CGFloat = view.frame.width - totalHorizonInset
        
        let itemWidth: CGFloat = contentsWidth / CGFloat(columns)
        
        return itemWidth
    }
    
    private func calculateItemHight(_ layout: UICollectionViewFlowLayout, rows: Int) -> CGFloat {
        let topInset: CGFloat = layout.sectionInset.top
        let bottomInset: CGFloat = layout.sectionInset.bottom
        let lineInset: CGFloat = layout.minimumLineSpacing
        let yOffset: CGFloat = layout.collectionView?.frame.origin.y ?? 0.0
        let totalVerticalInset: CGFloat = topInset + bottomInset + lineInset + yOffset
        let contentsHeight: CGFloat = view.frame.height - totalVerticalInset
        
        let itemHeight: CGFloat = contentsHeight / CGFloat(rows)
        
        return itemHeight
    }
}
