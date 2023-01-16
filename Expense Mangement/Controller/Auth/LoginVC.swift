//
//  LoginVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/9/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class LoginVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailErr: UILabel!
    
    @IBOutlet weak var pwdErr: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        let userRef = Firestore.firestore().collection("users")
        userRef.addSnapshotListener {(snapshot, _) in
            guard let snapshot = snapshot else {return}
            print("snapshot", snapshot)
            for document in snapshot.documents {
                print("users", document.data()[""])
            }
        }
        
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        if (emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true) {
            if emailTextField.text?.isEmpty == true {
               emailTextField.layer.borderColor = UIColor.red.cgColor
               emailTextField.layer.borderWidth = 1.0
               emailErr.text = "Email is required"
               emailErr.isHidden = false
           }

            if passwordTextField.text?.isEmpty == true {
               passwordTextField.layer.borderColor = UIColor.red.cgColor
               passwordTextField.layer.borderWidth = 1.0
               pwdErr.text = "Password is required" // works if you added labels
               pwdErr.isHidden = false

           }
        } else {
            login()
        }

    }
    
    
    @IBAction func createAccTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "register")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            [weak self] authResult, error  in
            guard self != nil else {return}
            if let error = error {
                print(error.localizedDescription)
            }
            
            self!.checkUserInfo()
        }
    }
    
    func checkUserInfo() {
        if Auth.auth().currentUser != nil {
            print("userId", Auth.auth().currentUser?.uid)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
}
