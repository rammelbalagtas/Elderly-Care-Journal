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
import FirebaseStorage
import FirebaseFirestoreSwift

class FamilyMemberListController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    
    var user: User!
    var familyMembers = [FamilyMember]()
    private let storage = Storage.storage().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        registerNib()

        tableView.delegate = self
        tableView.dataSource = self
        
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
            destination.user = user
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
    
    
    @IBAction func addFamilyMember(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let familyMemberDetailController = storyboard.instantiateViewController(identifier: "FamilyMemberDetailController") as FamilyMemberDetailController
        familyMemberDetailController.user = user
        show(familyMemberDetailController, sender: self)
    }
    
    @IBAction func unwindToFamilyMemberList( _ seg: UIStoryboardSegue) {
        loadData()
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
        cell.configureCell(using: familyMember, storage: storage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let familyMemberTabBarController = storyboard?.instantiateViewController(withIdentifier: "FamilyMemberGuardian") as? UITabBarController
        view.window?.rootViewController = familyMemberTabBarController
        view.window?.makeKeyAndVisible()
        
        var familyMember: FamilyMember?
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            familyMember = familyMembers[indexPaths[0].row]
        }
        
        guard let familyMember = familyMember else {
            return
        }
        
        let navControllers = familyMemberTabBarController?.viewControllers
        let memberDetailNavVC = navControllers?[0] as? UINavigationController
        let memberDetailVC = memberDetailNavVC?.topViewController as! FamilyMemberDetailController
        memberDetailVC.user = user
        memberDetailVC.familyMember = familyMember
        if user.userType != UserType.Guardian.rawValue {
            memberDetailVC.isEditable = false
        }
        
        let shiftListNavVC = navControllers?[1] as? UINavigationController
        let shiftListVC = shiftListNavVC?.topViewController as! ShiftListViewController
        shiftListVC.user = user
        shiftListVC.familyMember = familyMember
        
    }
    
}
