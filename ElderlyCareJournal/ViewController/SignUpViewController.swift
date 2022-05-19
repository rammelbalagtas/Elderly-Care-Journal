//
//  SignUpViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-16.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailAddressText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var retypePasswordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpAsGuardian(_ sender: UIButton) {
        signUp(as: .Guardian)
    }
    
    @IBAction func signUpAsCareProvider(_ sender: UIButton) {
        signUp(as: .CareProvider)
    }
    
    func signUp(as userType: UserType) {
        //validate fields
        let error = validateFields()

        if let error = error {
            showError(error)
        } else {
            
            //proceed with user creation
            let firstName = firstNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailAddress = emailAddressText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create user
            Auth.auth().createUser(withEmail: emailAddress, password: password)
            { (result, err) in
                if let err = err {
                    self.showError("\(err.localizedDescription)")
                } else {
                    guard
                        let result = result
                    else{
                        self.showError("User data couldn't be created")
                        return
                    }
                    
                    //create document and add to database
                    let db = Firestore.firestore()
                    let uid = result.user.uid as String
                    let user = User(uid: uid,
                                    emailAddress: emailAddress,
                                    userType: userType.rawValue,
                                    firstName: firstName,
                                    lastName: lastName)
                    
                    do {
                        let encoder = Firestore.Encoder()
                        try db.collection(Constants.Database.users).document(uid).setData(from: user, encoder: encoder, completion:
                        { (error) in
                            if let _ = error {
                                self.showError("User data couldn't be created")
                                return
                            }
                            self.transitionToHome(user: user)
                        })
                    } catch let error {
                        print("Error writing city to database: \(error)")
                    }
                }
            }
        }
    }
    
    // validate form fields
    func validateFields() -> String? {
        // check if all the fields are filled up
        if  firstNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailAddressText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            retypePasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        
        let cleanedPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedRetypePassword = retypePasswordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check password rules
        if !Utilities.isPasswordValid(cleanedPassword) {
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        } else {
            // check password match
            if cleanedPassword != cleanedRetypePassword {
                return "The passwords didn't match"
            }
        }
        return nil //means no error
    }
    
    //make error label visible to show error message
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(user: User) {
        if user.userType == UserType.Guardian.rawValue {
            let familyMemberListNavVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.familyMemberListNavVC) as? UINavigationController
            let familyMemberListVC = familyMemberListNavVC?.topViewController as! FamilyMemberListController
            familyMemberListVC.user = user
            view.window?.rootViewController = familyMemberListNavVC
            view.window?.makeKeyAndVisible()
        } else {
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
