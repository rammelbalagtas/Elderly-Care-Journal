//
//  FamilyMemberListController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class FamilyMemberListController: UIViewController, UITableViewDelegate {
    
    var user: User!
    var familyMembers = [FamilyMember]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNib()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        familyMembers = [FamilyMember]()
        let db = Firestore.firestore()
        db.collection(Constants.Database.familyMembers).whereField("uid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let familyMember = try document.data(as: FamilyMember.self)
                            self.familyMembers.append(familyMember)
                        } catch let error {
                            print("Error retrieving data: \(error.localizedDescription)")
                        }
                    }
                }
                self.tableView.reloadData()
        }
    }
    
    //Register nib for collection view and table view cells
    func registerNib() {
        let nibTable = UINib(nibName: Constants.NibName.nibFamilyMemberTable, bundle: nil)
        tableView.register(nibTable, forCellReuseIdentifier: Constants.ReuseIdentifier.familyMemberTableViewCell)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? FamilyMemberDetailController {
            destination.uid = user.uid
            if segue.identifier == "ViewMemberInformation" {
                if let indexPaths = tableView.indexPathsForSelectedRows {
                    destination.familyMember = familyMembers[indexPaths[0].row]
                    if user.userType != UserType.Guardian.rawValue {
                        destination.isEditable = false
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToFamilyMemberList( _ seg: UIStoryboardSegue) {
    }

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewMemberInformation", sender: self)
    }
    
}
