//
//  ClientTableViewCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-06.
//

import UIKit
import FirebaseStorage

class ClientTableViewCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientImage: UIImageView!
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerX = NSLayoutConstraint(item: self.clientImage!,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self.clientImage!,
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
        clientImage.maskCircle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(using client: FamilyMember, storage: StorageReference) {
        self.clientNameLabel.text = "\(client.firstName) \(client.lastName)"
        self.clientImage.image = nil
        let activityIndicator = self.activityIndicator
        activityIndicator.startAnimating()
        let path = "images/familymember/\(client.memberId).png"
        ImageStorageService.downloadImage(path: path, storage: storage)
        { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.clientImage.image = data
                }
                self.clientImage.image = data
            case .failure(let error):
                print(error.localizedDescription)
            }
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
}
