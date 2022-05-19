//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailAddressText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide error message during initial load
        errorLabel.alpha = 0
        
        //for testing purposes only
        emailAddressText.text = "test2@gmail.com"
        passwordText.text = "Test@1234"
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        // validate text fields
        let email = emailAddressText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" || password == "" {
            self.errorLabel.text = "Please fill in all fields"
            self.errorLabel.alpha = 1
            return
        }
        
        // signing in the user (firebase authentication)
        Auth.auth().signIn(withEmail: email, password: password)
        { (result, error) in
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                guard
                    let result = result
                else{
                    self.showError("User data couldn't be created")
                    return
                }
                let db = Firestore.firestore()
                let uid = result.user.uid as String
                let docRef = db.collection(Constants.Database.users).document("\(uid)")
                docRef.getDocument(as: User.self) { result in
                    switch result {
                    case .success(let user):
                        self.transitionToHome(user: user)
                    case .failure(let error):
                        self.showError(error.localizedDescription)
                    }
                }
                
            }
        }
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
    
    //make error label visible to show error message
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
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
