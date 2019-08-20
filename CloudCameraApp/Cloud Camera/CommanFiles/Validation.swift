//
//  Validation.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/9/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

class Validation: NSObject {

    static var errorMessage: String = ""

    class func isValidEmail(email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"//"^[A-Za-z0-9\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        print("\(emailPredicate.evaluate(with:email))")
        return emailPredicate.evaluate(with:email)
    }
    
    class func isValidUsername(username: String) -> Bool {
        
        let usernameRegEx = "\\w{3,18}"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
        return usernamePredicate.evaluate(with:username)
    }
}
