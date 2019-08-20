//
//  LoginVC.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/8/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import IQKeyboardManagerSwift

class LoginVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var animator: UIActivityIndicatorView!
    
    var radiusOfTextFieldBg: CGFloat = 5.0
    var radiusOfBtn: CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
    }
    
    @IBAction func onClickLoginBtn(_ sender: UIButton) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {
            
            if emailTxt.text?.count == 0 && passwordTxt.text?.count == 0 {
                
                ToastMessage.show(message: "Email and password can not be empty.", controller: self)
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
                loginWithEmail()
            }
        }
    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        
        AppUtils.clearTextField(textFields: [emailTxt, passwordTxt])
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func loginWithEmail() {
        
        animator.startAnimating()
        Auth.auth().signIn(withEmail: emailTxt.text!, password: passwordTxt.text!) { (authUser, error) in
                    
        if error != nil
        {
            self.animator.stopAnimating()
            print((error?.localizedDescription)!)
            ToastMessage.show(message: (error?.localizedDescription)!, controller: self)
        }
        else
        {
            guard let user = authUser?.user else {
                
                ToastMessage.show(message: "No such user found.", controller: self)
                self.animator.stopAnimating()
                return
            }
            print("\(user.uid) \(String(describing: user.email))")
            
            let userRef = AppConstant.FirebaseConstants.userRef.child(user.uid)
            
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.animator.stopAnimating()
                
                if snapshot.exists() {
                    
                    print("snapshot value\(String(describing: snapshot.value!))")

                    let userDic = snapshot.value! as! [String: Any]

                    AppPrefsManager.setUserID(userDic["user_id"] as! String)
                    AppPrefsManager.setUsername(userDic["username"] as! String)
                    
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarcontroller") as! TabBarController
                    UIApplication.shared.keyWindow?.rootViewController = tabBarVC;
                }
                else {
                    ToastMessage.show(message: "No such user found! Login with valid account.", controller: self)
                }
            })
            }
        }
    }

    //MARK: UITextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailTxt:
            passwordTxt.becomeFirstResponder()
            
        case passwordTxt:
            passwordTxt.resignFirstResponder()
            
        default: break
        }
        return true
    }
    
    func setUpLayout() {
        
        animator.stopAnimating()
        
        AppUtils.setCornerRadiusForView(view: emailView, radius: radiusOfTextFieldBg)
        AppUtils.setCornerRadiusForView(view: passwordView, radius: radiusOfTextFieldBg)
        AppUtils.setCornerRadiusForButton(button: loginBtn, radius: radiusOfBtn)
        
        IQKeyboardManager.shared.enable = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if emailTxt.becomeFirstResponder() {
            
            emailTxt.resignFirstResponder()
        } else {
            
            passwordTxt.resignFirstResponder()
        }
    }
}
