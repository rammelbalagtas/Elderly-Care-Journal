//
//  FamilyMemberTableViewCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit

class FamilyMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var familyMemberNameLabel: UILabel!
    @IBOutlet weak var familyMemberImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(using familyMember: FamilyMember) {
        self.familyMemberNameLabel.text = "\(familyMember.firstName) \(familyMember.lastName)"
//        self.familyMemberImage
    }
    
}
