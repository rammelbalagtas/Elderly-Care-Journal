//
//  SideNavigationMenuViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-30.
//

import UIKit

protocol SideNavigationMenuDelegate {
    func selectedCell(_ pageId: PageId)
}

class SideNavigationMenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: SideNavigationMenuDelegate?
    var userType: String!
    
    var defaultHighlightedCell: Int = 0
    
    var menu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "Family Members", pageId: .FamilyMemberList),
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "Clients", pageId: .ClientList),
        SideMenuModel(icon: UIImage(systemName: "person.circle.fill")!, title: "My Account", pageId: .MyAccount),
        SideMenuModel(icon: UIImage(systemName: "power")!, title: "Logout", pageId: .Login),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userType == UserType.Guardian.rawValue {
            menu.remove(at: 1) //remove Clients page
        } else {
            menu.remove(at: 0) //remove Family Members page
        }
        
        // TableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        // Set Highlighted Cell
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
            self.tableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        }
        
        // Register TableView Cell
        self.tableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)
        
        // Update TableView with the data
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension SideNavigationMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDataSource

extension SideNavigationMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell
            else { fatalError("xib doesn't exist") }

        cell.iconImage.image = self.menu[indexPath.row].icon
        cell.menuLabel.text = self.menu[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCell(menu[indexPath.row].pageId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

