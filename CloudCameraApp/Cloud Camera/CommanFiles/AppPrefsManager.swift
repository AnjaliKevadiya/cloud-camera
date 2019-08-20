//
//  UserDefaults.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/9/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import Foundation

class AppPrefsManager: NSObject {
    
    class func getUserID() -> String {
        return UserDefaults.standard.string(forKey: "USER_ID") ?? ""
    }

    class func setUserID(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "USER_ID")
    }
    
    class func getUsername() -> String {
        return UserDefaults.standard.string(forKey: "USERNAME") ?? ""
    }
    
    class func setUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: "USERNAME")
    }
    
    class func deleteUserID() {
        UserDefaults.standard.removeObject(forKey: "USER_ID")
    }
    
    class func deleteUsername() {
        UserDefaults.standard.removeObject(forKey: "USERNAME")
    }
}
