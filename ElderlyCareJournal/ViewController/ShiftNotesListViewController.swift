//
//  NotesListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit

class ShiftNotesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
//    var shift: Shift!
//    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
//        tableView.dataSource = self
        
        setupView()

    }
    
    private func setupView() {
//        if user.userType == UserType.CareProvider.rawValue {
//            self.navigationItem.rightBarButtonItem = nil
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShiftNotesListViewController: UITableViewDelegate {
    
}

//extension NotesListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//}
