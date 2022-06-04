//
//  ProfileTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-31.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UserProfileDelegate: AnyObject {
    func updateUser(user: User)
}

class UserProfileDetailController: UITableViewController {
    
    var user: User!
    weak var delegate: UserProfileDelegate?
    var isEditable: Bool = true
    private var shouldSavePhoto: Bool = false
    
    private let storage = Storage.storage().reference()

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var emailAddressText: UITextField!
    @IBOutlet weak var mobileNumberText: UITextField!
    @IBOutlet weak var streetText: UITextView!
    @IBOutlet weak var cityProvinceText: UITextView!
    @IBOutlet weak var postalCodeText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupView()
    }
    
    private func setupView() {
        
        // email address cannot be changed
        emailAddressText.isEnabled = false
        
        userImageView.maskCircle()
        
        streetText.delegate = self
        cityProvinceText.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

    }
    
    private func loadData() {
        firstNameText.text = user.firstName
        lastNameText.text = user.lastName
        if let age = user.age {
            ageText.text = String(age)
        }
        genderText.text = user.gender
        streetText.text = user.street
        cityProvinceText.text = user.cityProvince
        postalCodeText.text = user.postalCode
        countryText.text = user.country
        emailAddressText.text = user.emailAddress
        mobileNumberText.text = user.contactNumber
        if let photoPath = user.photo {
            self.userImageView.image = nil
            ImageStorageService.downloadImage(path: photoPath, storage: storage)
            { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.userImageView.image = data
                    }
                case .failure(let error):
                    //show error message
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func promptMessage(message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "", message: message , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        saveData()
    }
    
    @IBAction func updatePhotoAction(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func unwindFromGenderToUserProfile( _ seg: UIStoryboardSegue) {
    }
    
    private func saveData() {
        user.firstName = firstNameText.text ?? ""
        user.lastName = lastNameText.text ?? ""
        user.age = Int(ageText.text!) ?? 0
        user.gender = genderText.text ?? ""
        user.street = streetText.text ?? ""
        user.cityProvince = cityProvinceText.text ?? ""
        user.postalCode = postalCodeText.text ?? ""
        user.country = countryText.text ?? ""
        user.contactNumber = mobileNumberText.text ?? ""
        
        //add data validation
        
        //update firestore with new information
        var path: String?
        if let photoPath = user.photo {
            path = photoPath
        } else {
            if shouldSavePhoto {
                path = "images/user/\(user.uid).png"
            } else {
                path = nil
            }
            user.photo = path
        }
        
        UserDbService.update(user: user)
        { result in
            switch result {
            case .success(_):
                self.delegate?.updateUser(user: self.user)
                if let image = self.userImageView.image, let path = path {
                    ImageStorageService.uploadImage(path: path, image: image, storage: self.storage)
                    { result in
                        switch result {
                        case .success(_):
                            self.promptMessage(message: "User Profile record is updated", handler: nil)
                            return
                        case .failure(let error):
                            self.promptMessage(message: error.localizedDescription, handler: nil)
                            return
                        }
                    }
                }
            case .failure(let error):
                self.promptMessage(message: error.localizedDescription, handler: nil)
            }
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? GenderTableViewController {
            destination.isEditable = self.isEditable
            destination.gender = genderText.text
            destination.unwindSegue = "unwindFromGenderToUserProfile"
        }
    }
    

}

extension UserProfileDetailController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        self.userImageView.image = image
        shouldSavePhoto = true
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

extension UserProfileDetailController: UITextViewDelegate {
    // Resize textview depending on it's content
    func textViewDidChange(_ textView: UITextView) {
        var cell = UITableViewCell()
        if textView == streetText {
            cell = tableView.cellForRow(at: IndexPath(row: 1, section: 3))!
        } else if textView == cityProvinceText {
            cell = tableView.cellForRow(at: IndexPath(row: 2, section: 3))!
        }
        let newHeight = cell.frame.size.height + textView.contentSize.height
        cell.frame.size.height = newHeight
        updateTableViewContentOffsetForTextView()
    }
        
    // Animate cell, the cell frame will follow textView content
    func updateTableViewContentOffsetForTextView() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

