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

    private var difference: CGFloat = 0.0
    
    @IBAction func panningView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            guard let targetView = sender.view else {
                return
            }
            let translation = sender.translation(in: targetView)

            
            
            if noteListNav.view.frame.origin.x <= 0 && translation.x < 0 {
                return
            }
            
            if noteListNav.view.frame.origin.x >= menuVCWidth && translation.x > 0 {
                return
            }
            
            if noteListNav.view.frame.origin.x >= 0 && noteListNav.view.frame.origin.x <= menuVCWidth {
                difference += translation.x
                
                noteListVC.dimmingView.alpha = 0 + (0.75 * (noteListNav.view.frame.origin.x / menuVCWidth))
                noteListNav.view.frame.origin.x += translation.x
                sender.setTranslation(.zero, in: targetView)
            }
        case .ended:
            switch menuState {
            case .opened:
                if noteListNav.view.frame.origin.x > menuVCWidth * 0.8 {
                    openMenu(completion: nil)
                } else {
                    closeMenu(completion: nil)
                }
            case .closed:
                if noteListNav.view.frame.origin.x > view.frame.width * 0.2 {
                    openMenu(completion: nil)
                } else {
                    closeMenu(completion: nil)
                }
            }
        default:
            break
        }
        
        difference = 0.0
    }
}


// MARK: - NoteListViewControllerDelegate
extension ContainerViewController: NoteListViewControllerDelegate {
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
            self.noteListVC.dimmingView.alpha = 0.75
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
            self.noteListVC.dimmingView.alpha = 0.0
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
            showTagNoteListVC(tag: Tag())
        }
        
        toggleSideMenu(completion: nil)
    }
    
    func didTap(_ vc: MenuViewController, tag: Tag) {
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
        }
        print("Delete TagVC")
    }
    
    private func performSegue(mainMenu: MenuViewController.MainMenu) {
        let segueID = "to" + mainMenu.rawValue
        noteListVC.performSegue(withIdentifier: segueID, sender: nil)
    }
    
    private func showTagNoteListVC(tag: Tag) {
        if noteListVC.children.isEmpty {
            addTagNoteListVC(tag: tag)
        } else {
            replaceTagNoteListVC(tag: tag)
        }
    }
    
    private func addTagNoteListVC(tag: Tag) {
        guard let tagNoteListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteListViewController") as? NoteListViewController else {
            return
        }
        
        noteListVC.addChild(tagNoteListVC)
        noteListVC.view.addSubview(tagNoteListVC.view)
        tagNoteListVC.didMove(toParent: noteListVC)
        
        noteListVC.title = tag.name
        
        // TODO: - Tag에 해당하는 데이터를 불러오는 작업이 추가되어야합니다.
        print("Add TagNoteListVC")
    }
    
    private func replaceTagNoteListVC(tag: Tag) {
        if noteListVC.title == tag.name {
            return
        }
        
        guard let _ = noteListVC.children.first as? NoteListViewController else {
            return
        }
        
        noteListVC.title = tag.name
        
        // TODO: - Tag에 해당하는 데이터를 불러오는 작업이 추가되어야합니다.
        print("Replace TagNoteListVC")
    }
}

