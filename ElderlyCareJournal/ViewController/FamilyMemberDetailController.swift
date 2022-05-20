//
//  FamilyMemberDetailController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class FamilyMemberDetailController: UITableViewController {
    
    var isEditable: Bool = true
    var uid: String!
    var familyMember: FamilyMember?
    
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var streetText: UITextView!
    @IBOutlet weak var provinceText: UITextView!
    @IBOutlet weak var postalCodeText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var emergencyContactNameText: UITextField!
    @IBOutlet weak var emergencyContactNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupView()
    }
    
    private func setupView() {
//        tableView.estimatedRowHeight = 50
//        tableView.rowHeight = UITableView.automaticDimension
        
        //assign placeholders for text views (not supported by storyboard)
        if !streetText.text.isEmpty {
            streetText.placeholder = "Street"
        }
        if !provinceText.text.isEmpty {
            provinceText.placeholder = "City/Province"
        }
        memberImage.maskCircle()
    }
    
    //load data from dependency
    private func loadData() {
        if let familyMember = familyMember {
            firstNameText.text = familyMember.firstName
            lastNameText.text = familyMember.lastName
            ageText.text = String(familyMember.age)
            genderText.text = familyMember.gender
            streetText.text = familyMember.street
            provinceText.text = familyMember.provinceCity
            postalCodeText.text = familyMember.postalCode
            countryText.text = familyMember.country
            emergencyContactNameText.text = familyMember.emergencyContactName
            emergencyContactNumber.text = familyMember.emergencyContactNumber
        }
    }
    
    @IBAction func addChangePhotoAction(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        
        let firstName = firstNameText.text ?? ""
        let lastName = lastNameText.text ?? ""
        let age = Int(ageText.text!) ?? 0
        let gender = genderText.text ?? ""
        let street = streetText.text ?? ""
        let province = provinceText.text ?? ""
        let postalCode = postalCodeText.text ?? ""
        let country = countryText.text ?? ""
        let emergencyContactName = emergencyContactNameText.text ?? ""
        let emergencyContactNumber = emergencyContactNumber.text ?? ""

        //add data validation
        
        //update firestore with new information
        var memberId = ""
        if let _ = familyMember {
            memberId = familyMember!.memberId
            familyMember?.firstName = firstName
            familyMember?.lastName = lastName
            familyMember?.age = age
            familyMember?.gender = gender
            familyMember?.street = street
            familyMember?.provinceCity = province
            familyMember?.postalCode = postalCode
            familyMember?.country = country
            familyMember?.emergencyContactName = emergencyContactName
            familyMember?.emergencyContactNumber = emergencyContactNumber
        } else {
            memberId = UUID().uuidString
            self.familyMember = FamilyMember(uid: self.uid,
                                             memberId: memberId,
                                             firstName: firstName,
                                             lastName: lastName,
                                             age: age,
                                             gender: gender,
                                             street: street,
                                             provinceCity: province,
                                             postalCode: postalCode,
                                             country: country,
                                             emergencyContactName: emergencyContactName,
                                             emergencyContactNumber: emergencyContactNumber,
                                             photo: nil)
        }
        
        //create document and add to database
        let db = Firestore.firestore()
        
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.familyMembers).document(memberId).setData(from: familyMember, encoder: encoder, completion:
            { (error) in
                if let _ = error {
                    //show error
                    return
                }
                //navigate up to previous screen
                self.performSegue(withIdentifier: "unwindToFamilyMemberList", sender: self)
            })
        } catch let error {
            //show error message
            print("Error saving family member information: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        guard
            let familyMember = familyMember
        else {return}
        //create document and delete record from database
        let db = Firestore.firestore()
        
        db.collection(Constants.Database.familyMembers).document(familyMember.memberId).delete
        { (error) in
            if let _ = error {
                //show error
                return
            }
            //navigate up to previous screen
            self.performSegue(withIdentifier: "unwindToFamilyMemberList", sender: self)
        }
    }
    
    @IBAction func unwindFromGenderTableToFamilyMemberDetail( _ seg: UIStoryboardSegue) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //hide delete button when adding family members
        if let _ = familyMember {
            return 5
        } else {
            return 4
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? GenderTableViewController {
            destination.isEditable = self.isEditable
            destination.gender = genderText.text
        }
    }
    
}

extension FamilyMemberDetailController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.memberImage.image = image
        
    }
    
}
