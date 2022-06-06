//
//  ClientListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-06.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class ClientListViewController: UIViewController {
    
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    var clients = [FamilyMember]()
    
    private let storage = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        registerNib()

        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
    }
    
    private func registerNib() {
        
    }
    
    private func loadData() {
        FamilyMemberDbService.readClients(careProviderId: user.uid)
        { result in
            switch result {
            case .success(let data):
                self.clients = data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension ClientListViewController: UITableViewDelegate {
    
}

extension ClientListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
