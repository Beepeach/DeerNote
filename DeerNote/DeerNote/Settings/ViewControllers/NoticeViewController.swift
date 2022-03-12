//
//  NoticeViewController.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/28/22.
//

import UIKit
import FirebaseDatabase

class NoticeViewController: UIViewController {
    // MARK: Properties
    var dbReference: DatabaseReference?
    var notices: [Notice] = []
    
    // MARK: IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noticetableView: UITableView!
    
    // MARK: VCLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        dbReference = Database.database().reference()
        dbReference?.observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [Any] else {
                return
            }
            self.parsingData(data: value)
        })
    }
    
    private func parsingData(data: [Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let jsonDecoder = setupDecoder()
            
            let data = try jsonDecoder.decode([Notice].self, from: jsonData).sorted { $0.id > $1.id }
            self.notices = data
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.noticetableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    private func setupDecoder() -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return jsonDecoder
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let targetCell = sender as? NoticeTableViewCell else {
            return
        }
        guard let indexPath = noticetableView.indexPath(for: targetCell) else {
            return
        }
        guard let detailVC = segue.destination as? NoticeDetailViewController else {
            return
        }
        
        let data = notices[indexPath.row]
        detailVC.noticeTitle = data.title
        detailVC.date = data.date
        detailVC.contents = data.contents
    }
}

// MARK: - UITableViweDataSource
extension NoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as? NoticeTableViewCell else {
            return NoticeTableViewCell()
        }
        
        cell.titleLabel.text = notices[indexPath.row].title
        cell.dateLabel.text = shortDateFormatter.string(for: notices[indexPath.row].date)
        
        return cell
    }
}

