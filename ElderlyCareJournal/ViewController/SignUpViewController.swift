//
//  SignUpViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-16.
//

import UIKit
import FirebaseAuth
import Firebase

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
        signUp()
    }
    
    @IBAction func signUpAsCareProvider(_ sender: UIButton) {
        signUp()
    }
    
    func signUp() {
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
                if let _ = err {
                    self.showError("Error creating user")
                } else {
                    //create document and add to database
                    let db = Firestore.firestore()
                    db.collection(Constants.Database.users).addDocument(data: ["first_name": firstName,
                                                                               "last_name": lastName,
                                                                               "email_address": emailAddress,
                                                                               "uid": result!.user.uid])
                    { (error) in
                        if let _ = error {
                            self.showError("User data couldn't be created")
                        }
                        self.transitionToHome()
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
    
    //set HomeViewController as root controller after successful signup
    func transitionToHome() {
    
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
