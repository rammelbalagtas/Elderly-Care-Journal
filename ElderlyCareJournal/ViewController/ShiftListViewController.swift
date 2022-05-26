//
//  ShiftListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import UIKit

class ShiftListViewController: UIViewController {
    
    var user: User!
    var familyMember: FamilyMember!
    var shifts = [Shift]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ShiftDetailViewController {
            destination.uid = user.uid
            destination.memberId = familyMember.memberId
        }
    }

}
