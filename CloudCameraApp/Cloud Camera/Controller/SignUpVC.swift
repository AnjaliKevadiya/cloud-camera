//
//  SignUpVC.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/8/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import IQKeyboardManagerSwift

class SignUpVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    @IBOutlet weak var animator: UIActivityIndicatorView!
    
    var appUtils: AppUtils!
    var radiusOfTextFieldBg: CGFloat = 5.0
    var radiusOfBtn: CGFloat = 5.0
    var userRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {
         
            if fullnameTxt.text?.count == 0 && usernameTxt.text?.count == 0 && emailTxt.text?.count == 0 && passwordTxt.text?.count == 0 {
                ToastMessage.show(message: "This fields can not be empty.", controller: self)
            }
            else if fullnameTxt.text?.count == 0 {
                ToastMessage.show(message: "Fullname can not be empty", controller: self)
            }
            else if usernameTxt.text?.count == 0 {
                ToastMessage.show(message: "Username can not be empty.", controller: self)
            }
            else if Validation.isValidUsername(username: usernameTxt.text!) == false {
                ToastMessage.show(message: "Username must be of more than 3 characters.", controller: self)
            }
            else if emailTxt.text?.count == 0 {
                ToastMessage.show(message: "Email can not be empty.", controller: self)
            }
            else if Validation.isValidEmail(email: emailTxt.text!) == false {
                ToastMessage.show(message: "Invalid email! Try with valid one.", controller: self)
            }
            else if passwordTxt.text?.count == 0 {
                ToastMessage.show(message: "Password can not be empty.", controller: self)
            }
            else if (passwordTxt.text?.count)! <= 6 {
                ToastMessage.show(message: "Password must be of more than 6 digits.", controller: self)
            }
            else
            {
                signUpWithEmail()
            }
        }
    }
    
    @IBAction func onClickSignInBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

    func signUpWithEmail() {
        
        animator.startAnimating()
        
        Auth.auth().createUser(withEmail: emailTxt.text!, password: passwordTxt.text!) { (authUser, error) in
            
            if error != nil {
                self.animator.stopAnimating()
                print((error?.localizedDescription)!)
                ToastMessage.show(message: (error?.localizedDescription)!, controller: self)
            }
            else
            {
                guard let user = authUser?.user else { return }
                
                let uid = user.uid
                let email = user.email
                print("\(uid) \(String(describing: email))")
                                
                let userDic = ["user_id": uid,
                               "email": email,
                               "fullname": self.fullnameTxt.text!,
                               "username": self.usernameTxt.text!,
                               "password": self.passwordTxt.text!]
                
                AppConstant.FirebaseConstants.userRef.child(uid).setValue(userDic)
                self.animator.stopAnimating()
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: UITextFieldDelegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullnameTxt:
            usernameTxt.becomeFirstResponder()
            
        case usernameTxt:
            emailTxt.becomeFirstResponder()
            
        case emailTxt:
            passwordTxt.becomeFirstResponder()
            
        default:
            passwordTxt.resignFirstResponder()
        }
        return true
    }
    
    func setUpLayout() {
        
        animator.stopAnimating()
        
        AppUtils.setCornerRadiusForView(view: fullnameView, radius: radiusOfTextFieldBg)
        AppUtils.setCornerRadiusForView(view: usernameView, radius: radiusOfTextFieldBg)
        AppUtils.setCornerRadiusForView(view: emailView, radius: radiusOfTextFieldBg)
        AppUtils.setCornerRadiusForView(view: passwordView, radius: radiusOfTextFieldBg)
        
        AppUtils.setCornerRadiusForButton(button: signUpBtn, radius: radiusOfBtn)
        
        IQKeyboardManager.shared.enable = true
}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        emailTxt.resignFirstResponder()
    }
}
