//
//  TagSortTableViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/28/22.
//

import UIKit

class TagSortTableViewController: UITableViewController {
    // MARK: Properties
    var sort: Sort = {
        let sortString: String = UserDefaults.standard.string(forKey: TagSortTableViewController.tagSortUserInfoKey) ?? Sort.name.rawValue
        return Sort(rawValue: sortString) ?? .name
    }()
    var order: Sort =  {
        let orderString: String = UserDefaults.standard.string(forKey: TagSortTableViewController.tagOrderUserInfoKey) ?? Sort.descending.rawValue
        return Sort(rawValue: orderString) ?? .ascending
    }()
    
    
    // MARK:  VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserSelectedIndex()
        saveUserSelectedSort()
        NotificationCenter.default.post(name: .tagSortMenuWillDisappear, object: nil)
        
        print("Noti! \(UserDefaults.standard.string(forKey: TagSortTableViewController.tagSortUserInfoKey) ?? "") \(UserDefaults.standard.string(forKey: TagSortTableViewController.tagOrderUserInfoKey) ?? "")")
    }
    
    private func saveUserSelectedSort() {
        UserDefaults.standard.setValue(sort.rawValue, forKey: TagSortTableViewController.tagSortUserInfoKey)
        UserDefaults.standard.setValue(order.rawValue, forKey: TagSortTableViewController.tagOrderUserInfoKey)
    }
    
    private func saveUserSelectedIndex() {
        let selectedSortIndexPathRow = tableView.indexPathsForSelectedRows?.first{$0.section == 0}.map { $0.row } ?? 1
        let selectedOrderIndexPathRow = tableView.indexPathsForSelectedRows?.first{$0.section == 1}.map { $0.row } ?? 0
        print(selectedSortIndexPathRow, selectedOrderIndexPathRow)
        
        UserDefaults.standard.setValue(selectedSortIndexPathRow, forKey: "selectedTagSortIndexPathRow")
        UserDefaults.standard.setValue(selectedOrderIndexPathRow, forKey: "selectedTagOrderIndexPathRow")
    }
    
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userSelectedRow = UserDefaults.standard.value(forKey: "selectedTagOrderIndexPathRow") as? Int
        tableView.selectRow(at: IndexPath(row: userSelectedRow ?? 1, section: 1), animated: false, scrollPosition: .none)
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
                sort = .name
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
