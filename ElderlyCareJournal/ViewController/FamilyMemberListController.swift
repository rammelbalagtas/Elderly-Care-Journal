//
//  FamilyMemberListController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit

class FamilyMemberListController: UIViewController, UITableViewDelegate {
    
    var familyMembers = [FamilyMember]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNib()

        tableView.delegate = self
        tableView.dataSource = self
        
//        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        familyMembers.append(FamilyMember(firstName: "Mary", lastName: "Collins"))
        familyMembers.append(FamilyMember(firstName: "Mary", lastName: "Collins"))
        familyMembers.append(FamilyMember(firstName: "Mary", lastName: "Collins"))
    }
    
    //Register nib for collection view and table view cells
    func registerNib() {
        let nibTable = UINib(nibName: Constants.NibName.nibFamilyMemberTable, bundle: nil)
        tableView.register(nibTable, forCellReuseIdentifier: Constants.ReuseIdentifier.familyMemberTableViewCell)
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

extension FamilyMemberListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        familyMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifier.familyMemberTableViewCell, for: indexPath) as? FamilyMemberTableViewCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        let familyMember = familyMembers[indexPath.row]
        cell.configureCell(using: familyMember)
        return cell
    }
    
}
