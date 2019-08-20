//
//  AppConstant.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/15/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class AppConstant: NSObject {

    struct FirebaseConstants {
        
        static public let FirebaseStorageUrl = "YOUR_FIREBASE_STORAGE_URL"
        static public let FirebaseDatabaseUrl = "YOUR_FIREBASE_DATABASE_URL"
        
        static public let databaseRef = Database.database().reference()
        static public let storageRef = Storage.storage(url: FirebaseStorageUrl).reference()
        
        static let postRef = databaseRef.child("posts")
        static let userRef = databaseRef.child("users")
        static let postImagesRef = storageRef.child("PostImages")
    }
}
