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
                    let uid = result.user.uid as String
                    let user = User(uid: uid,
                                    emailAddress: emailAddress,
                                    userType: userType.rawValue,
                                    firstName: firstName,
                                    lastName: lastName)
                    UserDbService.create(user: user)
                    { result in
                        switch result {
                        case .success(_):
                            self.transitionToHome(user: user)
                        case .failure(let error):
                            self.showError(error.localizedDescription)
                            return
                        }
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
        let pageContainer = storyboard?.instantiateViewController(withIdentifier: "PageContainer") as! PageContainerViewController
        pageContainer.user = user
        if user.userType == UserType.Guardian.rawValue {
            pageContainer.defaultPageId = .FamilyMemberList
        } else {
            pageContainer.defaultPageId = .ClientList
        }
        view.window?.rootViewController = pageContainer
        view.window?.makeKeyAndVisible()
    }

}
