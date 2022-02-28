//
//  NoteSortTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/28/22.
//

import UIKit
import CoreData


class NoteSortTableViewController: UITableViewController {
    // MARK: Properties
    var sort: Sort = {
        let sortString: String = UserDefaults.standard.string(forKey: NoteSortTableViewController.noteSortUserInfoKey) ?? Sort.modifiedDate.rawValue
        return Sort(rawValue: sortString) ?? .modifiedDate
    }()
    var order: Sort =  {
        let orderString: String = UserDefaults.standard.string(forKey: NoteSortTableViewController.noteOrderUserInfoKey) ?? Sort.descending.rawValue
        return Sort(rawValue: orderString) ?? .descending
    }()
    
    
    // MARK:  VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserSelectedIndex()
        saveUserSelectedSort()
        NotificationCenter.default.post(name: .noteSortMenuWillDisappear, object: nil)
        
        print("Noti! \(UserDefaults.standard.string(forKey: NoteSortTableViewController.noteSortUserInfoKey) ?? "") \(UserDefaults.standard.string(forKey: NoteSortTableViewController.noteOrderUserInfoKey) ?? "")")
    }
    
    private func saveUserSelectedSort() {
        UserDefaults.standard.setValue(sort.rawValue, forKey: NoteSortTableViewController.noteSortUserInfoKey)
        UserDefaults.standard.setValue(order.rawValue, forKey: NoteSortTableViewController.noteOrderUserInfoKey)
    }
    
    private func saveUserSelectedIndex() {
        let selectedSortIndexPathRow = tableView.indexPathsForSelectedRows?.first{$0.section == 0}.map { $0.row } ?? 2
        let selectedOrderIndexPathRow = tableView.indexPathsForSelectedRows?.first{$0.section == 1}.map { $0.row } ?? 1
        print(selectedSortIndexPathRow, selectedOrderIndexPathRow)
        
        UserDefaults.standard.setValue(selectedSortIndexPathRow, forKey: "selectedNoteSortIndexPathRow")
        UserDefaults.standard.setValue(selectedOrderIndexPathRow, forKey: "selectedNoteOrderIndexPathRow")
    }
    
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userSelectedRow = UserDefaults.standard.value(forKey: "selectedNoteSortIndexPathRow") as? Int
        tableView.selectRow(at: IndexPath(row: userSelectedRow ?? 2, section: 0), animated: false, scrollPosition: .none)
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath), !cell.isSelected else {
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPathsInSection = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
            print("Selected Index in Setcion \(selectedIndexPathsInSection)")
            selectedIndexPathsInSection.forEach({ tableView.deselectRow(at: $0, animated: true) })
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                sort = .contents
            } else if indexPath.row == 1 {
                sort = .createdDate
            } else {
                sort = .modifiedDate
            }
        default:
            if indexPath.row == 0 {
                order = .ascending
            } else {
                order = .descending
            }
        }
        print(sort, order)
    }
}
