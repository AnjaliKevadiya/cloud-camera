//
//  User.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/8/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

class User {

    var fullname: NSString!
    var username: NSString!
    var email: NSString!
    var password: NSString!
    
    init(fullname: NSString, username: NSString, email: NSString, password: NSString) {
        self.fullname = fullname
        self.username = username
        self.email = email
        self.password = password
    }
}
