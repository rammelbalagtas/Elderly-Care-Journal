//
//  ShiftListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import UIKit

class ShiftListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    var familyMember: FamilyMember!
    var shifts = [Shift]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToShiftListController( _ seg: UIStoryboardSegue) {
        loadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewShift", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ShiftDetailViewController {
            destination.uid = user.uid
            destination.memberId = familyMember.memberId
            if segue.identifier == "ViewShift" {
                if let indexPaths = tableView.indexPathsForSelectedRows {
                    destination.shift = shifts[indexPaths[0].row]
                }
            }
        }
    }
    
    private func loadData() {
        ShiftDbService.readAll(memberId: familyMember.memberId, status: ShiftStatus.New.rawValue )
        { result in
            switch result {
            case .success(let data):
                self.shifts = data
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension ShiftListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "Shift")
        else{preconditionFailure("Unable to dequeue reusable cell")}
        let shift = shifts[indexPath.row]
        cell.textLabel?.text = shift.description
        return cell
    }
}
