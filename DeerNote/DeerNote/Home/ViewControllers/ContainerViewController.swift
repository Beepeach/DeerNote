//
//  ContainerViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/10/22.
//

import UIKit
import CloudKit

class ContainerViewController: UIViewController {
    enum MenuState {
        case opened
        case closed
    }
    
    private var menuState: MenuState = .closed
    
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
    
    private var menuVCWidth: CGFloat {
        return view.frame.width * 0.8
    }

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
}

extension ContainerViewController: MenuViewControllerDeleagete {
    func didTap(_ vc: MenuViewController, mainMenu: MenuViewController.MainMenu) {
        toggleSideMenu(completion: nil)
    }
    
    func didTap(_ vc: MenuViewController, tag: Tag) {
        toggleSideMenu(completion: nil)
    }
}


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
        } completion: { [weak self] done in
            if done {
                self?.menuState = .closed
                completion?()
            }
        }
    }
}
