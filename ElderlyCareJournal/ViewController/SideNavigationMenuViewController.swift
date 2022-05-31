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
    
    var defaultHighlightedCell: Int = 0
    
    var menu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "Family Member List", pageId: .FamilyMemberList),
        SideMenuModel(icon: UIImage(systemName: "person.circle.fill")!, title: "My Account", pageId: .MyAccount),
        SideMenuModel(icon: UIImage(systemName: "power")!, title: "Logout", pageId: .Login),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        // Highlighted color
//        let myCustomSelectionColorView = UIView()
//        myCustomSelectionColorView.backgroundColor = UIColor.systemGray5
//        cell.selectedBackgroundView = myCustomSelectionColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCell(menu[indexPath.row].pageId)
//        // Remove highlighted color when you press the 'Profile' and 'Like us on facebook' cell
//        if indexPath.row == 4 || indexPath.row == 6 {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
    }
}

