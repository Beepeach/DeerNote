//
//  ContainerViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/10/22.
//

import UIKit
import CloudKit

class ContainerViewController: UIViewController {
    // MARK: Enum
    enum MenuState {
        case opened
        case closed
    }
    
    
    // MARK: Properties
    private var menuState: MenuState = .closed
    private var differenceFromFirstTouch: CGFloat = 0.0
    
    private var menuVCWidth: CGFloat {
        return view.frame.width * 0.8
    }
    private let menuVC: MenuViewController = {
        guard let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else {
            return MenuViewController()
        }
        
        return menuVC
    }()
    private let noteListNav: UINavigationController = {
        guard let noteListNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteListNavigationController") as? UINavigationController else {
            return UINavigationController(rootViewController: NoteListViewController())
        }
        
        return noteListNav
    }()
    private lazy var noteListVC: NoteListViewController = noteListNav.viewControllers.first as? NoteListViewController ?? NoteListViewController()
    private var visibleNoteListVC: NoteListViewController {
        if noteListVC.children.isEmpty {
            return noteListVC
        }
        
        guard let tagNoteListVC = noteListVC.children.last as? NoteListViewController else {
            return noteListVC
        }
        
        return tagNoteListVC
    }

    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVCs()
    }
    
    private func addChildVCs() {
        addMenuVC()
        addNoteListNav()
    }
    
    private func addMenuVC() {
        menuVC.delegate = self
        
        addChild(menuVC)
        menuVC.view.frame = CGRect(x: 0, y: 0, width: self.menuVCWidth, height: self.view.frame.height)
        view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
    }
    
    private func addNoteListNav() {
        noteListVC.delegate = self
        
        addChild(noteListNav)
        view.addSubview(noteListNav.view)
        noteListNav.didMove(toParent: self)
    }
    
    // MARK: CustomMethods
    override var shouldAutorotate: Bool {
        if menuState == .opened {
            return false
        }
        
        return true
    }
    
  
    // MARK: @IBAction
    @IBAction func panningView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            guard let targetView = sender.view else {
                return
            }
            let translation: CGPoint = sender.translation(in: targetView)
            
            if canMovecheckNoteListNav(from: translation) {
                moveNoteList(from: translation)
                setDynamicDimmingViewAlpha()
            }
            sender.setTranslation(.zero, in: targetView)
        case .ended, .cancelled, .failed:
            switch menuState {
            case .opened:
                let isNearRightSide :Bool = noteListNav.view.frame.origin.x > menuVCWidth * 0.8
                completeMenuAnimation(on: isNearRightSide)
            case .closed:
                let isNotNearLeftSide: Bool = noteListNav.view.frame.origin.x > view.frame.width * 0.2
                completeMenuAnimation(on: isNotNearLeftSide)
            }
        default:
            break
        }
        
        differenceFromFirstTouch = 0.0
    }
    
    private func canMovecheckNoteListNav(from translation: CGPoint) -> Bool {
        if isWrong(touch: translation) {
            return false
        }
        let isCorrectMoveBound: Bool = noteListNav.view.frame.origin.x >= 0 && noteListNav.view.frame.origin.x <= menuVCWidth
        
        if isCorrectMoveBound {
            return true
        }
        return false
    }
    
    private func isWrong(touch translation: CGPoint) -> Bool {
        let isLeftWrongTouch: Bool = noteListNav.view.frame.origin.x <= 0 && translation.x < 0
        let isRightWrongTouch: Bool = noteListNav.view.frame.origin.x >= menuVCWidth && translation.x > 0
        
        if isLeftWrongTouch || isRightWrongTouch {
            return true
        }
        
        return false
    }
    
    private func moveNoteList(from translation: CGPoint) {
        differenceFromFirstTouch += translation.x
        noteListNav.view.frame.origin.x += translation.x
    }
    
    private func setDynamicDimmingViewAlpha() {
        visibleNoteListVC.dimmingView.alpha = 0 + (0.5 * (noteListNav.view.frame.origin.x / menuVCWidth))
    }
    
    private func completeMenuAnimation(on condition: Bool) {
        if condition {
            openMenu(completion: nil)
        } else {
            closeMenu(completion: nil)
        }
    }
}



// MARK: - NoteListViewControllerDelegate
extension ContainerViewController: NoteListViewControllerDelegate {
    func didTapDimmingView(_ vc: NoteListViewController) {
        closeMenu(completion: nil)
    }
    
    func didTapMenuButton(_ vc: NoteListViewController) {
        toggleSideMenu(completion: nil)
    }
    
    func toggleSideMenu(completion: (() -> Void)?) {
        switch menuState {
        case .closed:
           openMenu(completion: completion)
        case .opened:
            closeMenu(completion: completion)
        }
    }
    
    private func openMenu(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.noteListNav.view.frame.origin.x = self.noteListNav.view.frame.width * 0.8
            self.visibleNoteListVC.dimmingView.alpha = 0.5
        } completion: { [weak self] done in
            if done {
                self?.menuState = .opened
                completion?()
            }
        }
    }
    
    private func closeMenu(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.noteListNav.view.frame.origin.x = 0
            self.visibleNoteListVC.dimmingView.alpha = 0.0
        } completion: { [weak self] done in
            if done {
                self?.menuState = .closed
                completion?()
            }
        }
    }
}


// MARK: - MenuViewControllerDelegate
extension ContainerViewController: MenuViewControllerDeleagete {
    func didTap(_ vc: MenuViewController, mainMenu: MenuViewController.MainMenu) {
        switch mainMenu {
        case .all:
            resetTagNoteVC()
            noteListNav.popToRootViewController(animated: true)
        case .trash:
            performSegue(mainMenu: mainMenu)
        case .settings:
            performSegue(mainMenu: mainMenu)
        case .untagged:
            showTagNoteListVC(tag: nil)
        }
        
        toggleSideMenu(completion: nil)
    }
    
    func didTap(_ vc: MenuViewController, tag: TagEntity) {
        toggleSideMenu(completion: nil)
        showTagNoteListVC(tag: tag)
    }
    
    private func resetTagNoteVC() {
        if !noteListVC.children.isEmpty {
            guard let tagNoteVC = noteListVC.children.first as? NoteListViewController else {
                return
            }
            tagNoteVC.view.removeFromSuperview()
            tagNoteVC.removeFromParent()
            
            noteListVC.title = "All"
            noteListVC.tag = nil
            noteListVC.isTagVC = false
        }
        print("Delete TagVC")
    }
    
    private func performSegue(mainMenu: MenuViewController.MainMenu) {
        let segueID = "to" + mainMenu.rawValue
        noteListVC.performSegue(withIdentifier: segueID, sender: nil)
    }
    
    private func showTagNoteListVC(tag: TagEntity?) {
        if noteListVC.children.isEmpty {
            addTagNoteListVC(tag: tag)
        } else {
            replaceTagNoteListVC(tag: tag)
        }
    }
    
    private func addTagNoteListVC(tag: TagEntity?) {
        guard let tagNoteListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteListViewController") as? NoteListViewController else {
            return
        }
        
        if let tag = tag {
            noteListVC.title = tag.name
            tagNoteListVC.tag = tag
            tagNoteListVC.isTagVC = true
        } else {
            noteListVC.title = "Untagged"
            tagNoteListVC.isTagVC = true
        }
        
        noteListVC.addChild(tagNoteListVC)
        noteListVC.view.addSubview(tagNoteListVC.view)
        tagNoteListVC.didMove(toParent: noteListVC)
        print("Add TagNoteListVC")
    }
    
    private func replaceTagNoteListVC(tag: TagEntity?) {
        if noteListVC.title == tag?.name ?? "Untagged" {
            return
        }
        guard let targetNoteListVC = noteListVC.children.first as? NoteListViewController else {
            return
        }
        noteListVC.title = tag?.name ?? "Untagged"
        targetNoteListVC.tag = tag
        targetNoteListVC.isTagVC = true
        NotificationCenter.default.post(name: .tagNoteVCWillReplaced, object: nil)
        print("Replace TagNoteListVC")
    }
}


// MARK: - UIGestureRecognizerDelegate
extension ContainerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        guard isNoteListVC() else {
            return false
        }
        let translation = panGestureRecognizer.translation(in: view)
        let isAlomstHorizontalPanning: Bool = abs(translation.x) > abs(translation.y)
        if isAlomstHorizontalPanning {
            return true
        }
        return false
    }
    
    private func isNoteListVC() -> Bool {
        if let _ = noteListNav.topViewController as? NoteListViewController {
            return true
        }
        
        return false
    }
}



