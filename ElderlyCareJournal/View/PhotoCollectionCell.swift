//
//  PhotoCollectionCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit
import FirebaseStorage

protocol PhotoCollectionDelegate: AnyObject {
    func removePhoto(at indexPath: IndexPath)
}

class PhotoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: PhotoCollectionDelegate!
    var indexPath: IndexPath!
    
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        delegate.removePhoto(at: indexPath)
    }
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerX = NSLayoutConstraint(item: self.photoImageView!,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self.photoImageView!,
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
        deleteBtn.isHidden = true
    }
    
    func configureImage(path: String?, image: UIImage?, storage: StorageReference) {
        if let image = image {
            deleteBtn.isHidden = false
            photoImageView.image = image
        }
        else if let path = path {
            deleteBtn.isHidden = true
            self.photoImageView.image = nil
            let activityIndicator = self.activityIndicator
            activityIndicator.startAnimating()
            ImageStorageService.downloadImage(path: path, storage: storage)
            { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.photoImageView.image = data
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.deleteBtn.isHidden = false
            }
        }
    }

}
