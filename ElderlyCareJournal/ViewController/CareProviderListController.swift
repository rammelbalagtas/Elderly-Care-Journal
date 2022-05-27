//
//  CareProviderListController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-27.
//

import UIKit

protocol CareProviderListDelegate: AnyObject {
    func assignCareProvider(careProvider: User)
}

class CareProviderListController: UIViewController, UITableViewDelegate {
    
    var careProviderList = [User]()
    private var filteredResults = [User]()
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: CareProviderListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupSearchBarController()
        
        UserDbService.readAll(userType: UserType.CareProvider.rawValue)
        { result in
            switch result {
            case .success(let data):
                self.careProviderList = data
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.assignCareProvider(careProvider: careProviderList[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Care Provider"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredResults = careProviderList.filter
        { (user: User) -> Bool in
            let fullname = "\(user.firstName) \(user.lastName)"
            return fullname.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
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

extension CareProviderListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredResults.count
        }
        return careProviderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CareProvider")
        else{preconditionFailure("unable to dequeue reusable cell")}
        let careProvider: User
        if isFiltering {
            careProvider = filteredResults[indexPath.row]
        } else {
            careProvider = careProviderList[indexPath.row]
        }
        cell.textLabel?.text = "\(careProvider.firstName) \(careProvider.lastName)"
        return cell
    }
}

extension CareProviderListController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      let searchBar = searchController.searchBar
      filterContentForSearchText(searchBar.text!)
  }
}

