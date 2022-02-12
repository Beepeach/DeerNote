//
//  NoteEditorViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/12/22.
//

import UIKit

class NoteEditorViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var EndEditBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .systemTeal
        
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
}
