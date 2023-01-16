//
//  RegisterVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/9/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@available(iOS 13.0, *)
class RegisterVC: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
//    Error
    
    
    @IBOutlet weak var nameErr: UILabel!
    @IBOutlet weak var emailErr: UILabel!
    @IBOutlet weak var pwdErr: UILabel!
    @IBOutlet weak var confirmPwdErr: UILabel!
    
    
    let userRef = Firestore.firestore().collection("users")
    
    @IBAction func nameChanged(_ sender: Any) {
        if #available(iOS 13.0, *) {
            nameTextField.layer.borderColor = UIColor.systemGray3.cgColor
            nameTextField.layer.borderWidth = 1.0
            nameErr.isHidden = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func changeEmail(_ sender: Any) {
        emailTextField.layer.borderColor = UIColor.systemGray3.cgColor
        emailTextField.layer.borderWidth = 1.0
        emailErr.isHidden = true
    }
    
    
    @IBAction func pwdChanged(_ sender: Any) {
        passwordTextField.layer.borderColor = UIColor.systemGray3.cgColor
        passwordTextField.layer.borderWidth = 1.0
        pwdErr.isHidden = true
    }
    
    
    @IBAction func confirmPwdChanged(_ sender: Any) {
        confirmPasswordTextField.layer.borderColor = UIColor.systemGray3.cgColor
        confirmPasswordTextField.layer.borderWidth = 1.0
        confirmPwdErr.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.isSecureTextEntry = true
    }

    
    @IBAction func registerTapped(_ sender: Any) {
    
        if(nameTextField.text?.isEmpty == true || emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true || confirmPasswordTextField.text?.isEmpty == true || passwordTextField.text!.count < 6) {
            if nameTextField.text?.isEmpty == true {
                nameTextField.layer.borderColor = UIColor.red.cgColor
                nameTextField.layer.borderWidth = 1.0
                nameErr.text = "Name is required"
                nameErr.isHidden = false
            } else if (nameTextField.text!.count >= 1) {
                nameChanged(nameTextField!)
            }
            
             if emailTextField.text?.isEmpty == true {
                emailTextField.layer.borderColor = UIColor.red.cgColor
                emailTextField.layer.borderWidth = 1.0
                emailErr.text = "Email is required"
                emailErr.isHidden = false
             } else if (emailTextField.text!.count >= 1) {
                 changeEmail(emailTextField!)
             }
            
            if passwordTextField.text?.isEmpty == true {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
                passwordTextField.layer.borderWidth = 1.0
                pwdErr.text = "Password is required"
                pwdErr.isHidden = false
            }else if (passwordTextField.text!.count < 6) {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
                passwordTextField.layer.borderWidth = 1.0
                pwdErr.text = "Password must be at least 6 character"
                pwdErr.isHidden = false
            } else {
                pwdChanged(passwordTextField!)
            }
            
             if confirmPasswordTextField.text?.isEmpty == true {
                confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
                confirmPasswordTextField.layer.borderWidth = 1.0
                confirmPwdErr.text = "Confirm password is required"
                confirmPwdErr.isHidden = false
             }
            if confirmPasswordTextField !== passwordTextField {
                 confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
                 confirmPasswordTextField.layer.borderWidth = 1.0
                 confirmPwdErr.text = "Confirm Password do not match"
                 confirmPwdErr.isHidden = false
             } else {
                 confirmPwdChanged(confirmPasswordTextField!)
             }
        } else {
            register()
        }
    }
    
    @IBAction func haveAccTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    
    func register() {
        
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { [self] (authResutlt, error) in
                guard let user = authResutlt?.user, error == nil else {
                    print("Error \(String(describing: error?.localizedDescription))")
                    return
                }

                let parameters: [String: Any] = [
                    "name": nameTextField.text ?? "",
                    "email": emailTextField.text ?? "",
                    "password": passwordTextField.text ?? "",
                    "confirmPassword": confirmPasswordTextField.text ?? ""
                ]

                userRef.addDocument(data: parameters)


                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
        }
    }
    
}
