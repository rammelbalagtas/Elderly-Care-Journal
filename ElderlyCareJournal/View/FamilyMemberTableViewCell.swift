//
//  FamilyMemberTableViewCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit
import FirebaseStorage

class FamilyMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var familyMemberNameLabel: UILabel!
    @IBOutlet weak var familyMemberImage: UIImageView!
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerX = NSLayoutConstraint(item: self.familyMemberImage!,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self.familyMemberImage!,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        self.addConstraints([centerX, centerY])
        return activityIndicator
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        familyMemberImage.maskCircle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(using familyMember: FamilyMember, storage: StorageReference) {
        self.familyMemberNameLabel.text = "\(familyMember.firstName) \(familyMember.lastName)"
        self.familyMemberImage.image = nil
        let activityIndicator = self.activityIndicator
        activityIndicator.startAnimating()
        let path = "images/familymember/\(familyMember.memberId).png"
        ImageStorageService.downloadImage(path: path, storage: storage)
        { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.familyMemberImage.image = data
                }
                self.familyMemberImage.image = data
            case .failure(let error):
                print(error.localizedDescription)
            }
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
}
