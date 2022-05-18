//
//  LoginViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-16.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailAddressText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide error message during initial load
        errorLabel.alpha = 0
        
        //for testing purposes only
        emailAddressText.text = "test1@gmail.com"
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
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.alpha = 1
            } else {
                self.transitionToHome()
            }
        }
    }
    
    func transitionToHome() {
        let familyMemberListNavVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.familyMemberListNavVC) as? UINavigationController
        view.window?.rootViewController = familyMemberListNavVC
        view.window?.makeKeyAndVisible()
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
