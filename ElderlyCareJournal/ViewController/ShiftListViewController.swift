//
//  ShiftListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import UIKit

class ShiftListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    
    var user: User!
    var familyMember: FamilyMember!
    var shifts = [Shift]()
    var selectedSegment = 0
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        registerNib()
        loadData(status: ShiftStatus.New.rawValue) //default tab is Scheduled
        
    }
    
    @IBAction func unwindToShiftListController( _ seg: UIStoryboardSegue) {
        statusSegment.selectedSegmentIndex = self.selectedSegment
        switch self.selectedSegment {
        case 0:
            loadData(status: ShiftStatus.New.rawValue)
        case 1:
            loadData(status: ShiftStatus.InProgress.rawValue)
        case 2:
            loadData(status: ShiftStatus.Completed.rawValue)
        default:
            loadData(status: ShiftStatus.New.rawValue)
        }
    }
    
    
    @IBAction func switchStatus(_ sender: UISegmentedControl) {
        var status = ""
        self.selectedSegment = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            status = ShiftStatus.New.rawValue
        case 1:
            status = ShiftStatus.InProgress.rawValue
        case 2:
            status = ShiftStatus.Completed.rawValue
        default:
            status = ShiftStatus.New.rawValue
        }
        loadData(status: status)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewShift", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ShiftDetailViewController {
            destination.user = user
            destination.memberId = familyMember.memberId
            if segue.identifier == "ViewShift" {
                if let indexPaths = tableView.indexPathsForSelectedRows {
                    destination.shift = shifts[indexPaths[0].row]
                }
            }
        }
    }
    
    private func registerNib() {
        // Register TableView Cell
        self.tableView.register(ShiftTableViewCell.nib, forCellReuseIdentifier: ShiftTableViewCell.identifier)
    }
    
    private func setupView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //setup side menu
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        if user.userType == UserType.CareProvider.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: " Fetching shift records ...")
        
    }
    
    private func loadData(status: String) {
        var careProviderId: String?
        if user.userType == UserType.CareProvider.rawValue {
            careProviderId = user.uid
        }
        tableView.isHidden = true
        self.activityIndicator.startAnimating()
        ShiftDbService.readWithFilter(memberId: familyMember.memberId, careProviderId: careProviderId, status: status )
        { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.shifts = data
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
    
    @objc private func pullToRefreshAction(_ sender: Any) {
        // Fetch shift records
        switch self.selectedSegment {
        case 0:
            loadData(status: ShiftStatus.New.rawValue)
        case 1:
            loadData(status: ShiftStatus.InProgress.rawValue)
        case 2:
            loadData(status: ShiftStatus.Completed.rawValue)
        default:
            loadData(status: ShiftStatus.New.rawValue)
        }
    }

}

extension ShiftListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ShiftTableViewCell.identifier, for: indexPath) as? ShiftTableViewCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        
        let shift = shifts[indexPath.row]
        cell.configureCell(using: shift)
        return cell
    }
}
