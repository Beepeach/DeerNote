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
        addChild(menuVC)
        menuVC.view.frame = CGRect(x: 0, y: 0, width: self.menuVCWidth, height: self.view.frame.height)
        view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
    }
    
    private func addNoteListNav() {
        addChild(noteListNav)
        view.addSubview(noteListNav.view)
        noteListNav.didMove(toParent: self)
    }
}
