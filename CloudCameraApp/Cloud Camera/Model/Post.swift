//
//  Post.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/10/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

class Post {

    var postId: String
    var userId: String
    var username: String
    var imgUrl: String
    var caption: String
    var created_at: String
    var total_likes: NSNumber
    
    init(postId: String, userId: String, username: String, imgUrl: String, caption: String, created_at: String, total_likes: NSNumber) {
        
        self.postId = postId
        self.userId = userId
        self.username = username
        self.imgUrl = imgUrl
        self.caption = caption
        self.created_at = created_at
        self.total_likes = total_likes
    }
    
}
