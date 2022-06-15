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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var refreshControl = UIRefreshControl()
    
    var user: User!
    var clients = [FamilyMember]()
    
    private let storage = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        setupView()
        loadData()
    }
    
    private func registerNib() {
        // Register TableView Cell
        self.tableView.register(ClientTableViewCell.nib, forCellReuseIdentifier: ClientTableViewCell.identifier)
    }
    
    private func setupView() {
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(pullUpToRefreshAction), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching client records ...")
        tableView.addSubview(refreshControl)
    }
    
    @objc
    private func pullUpToRefreshAction() {
        loadData()
    }
    
    private func loadData() {
        self.tableView.isHidden = true
        self.activityIndicator.startAnimating()
        FamilyMemberDbService.readClients(careProviderId: user.uid)
        { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.clients = data
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                }
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
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.identifier, for: indexPath) as? ClientTableViewCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        
        let client = clients[indexPath.row]
        cell.configureCell(using: client, storage: storage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var client: FamilyMember?
        if let indexPaths = tableView.indexPathsForSelectedRows {
            client = clients[indexPaths[0].row]
        }
        guard let client = client else {
            return
        }
        let pageContainer = storyboard?.instantiateViewController(withIdentifier: "PageContainer") as! PageContainerViewController
        pageContainer.user = user
        pageContainer.familyMember = client
        pageContainer.defaultPageId = .FamilyMemberDetail
        view.window?.rootViewController = pageContainer
        view.window?.makeKeyAndVisible()
        
    }
    
    
}
