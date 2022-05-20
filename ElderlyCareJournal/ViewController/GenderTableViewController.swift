//
//  GenderTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit

class GenderTableViewController: UITableViewController {
    
    var isEditable: Bool = true
    var gender: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "Gender")
        else{preconditionFailure("unable to dequeue reusable cell")}
        if indexPath.row == 0 {
            cell.textLabel?.text = Gender.Male.rawValue
            if gender == Gender.Male.rawValue {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.textLabel?.text = Gender.Female.rawValue
            if gender == Gender.Female.rawValue {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isEditable { return }
        
        if indexPath.row == 0 {
            self.gender = Gender.Male.rawValue
        } else {
            self.gender = Gender.Female.rawValue
        }
        //navigate up to previous screen
        self.performSegue(withIdentifier: "unwindFromGenderTableToFamilyMemberDetail", sender: self)
    }

    
    // MARK: - Navigation
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? FamilyMemberDetailController {
            destination.genderText.text = self.gender
        }
    }
    

}
