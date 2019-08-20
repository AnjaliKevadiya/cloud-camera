//
//  PostDetailVC.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/16/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import IQKeyboardManagerSwift

class PostDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextField!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    var postImage: UIImage!
    var postDic = [Post]()
    var isSendComment: Bool = false
    var commentDic = [[String : String]]()
    var currentPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCurrentUserLikedPost()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        currentPost = self.postDic[0]
        
        if let currentPost = currentPost, !currentPost.postId.isEmpty {
            
            self.getLikeDislikeLiveValues(postID: currentPost.postId)
        }
        getAllComments()

        let tableViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTableView))
        tableViewTapGesture.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(tableViewTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        IQKeyboardManager.shared.enable = false
        

        tableView.register(UINib(nibName: "PostImageCell", bundle: nil), forCellReuseIdentifier: "PostImageCell")
        tableView.register(UINib(nibName: "LikeMoreCommentCell", bundle: nil), forCellReuseIdentifier: "LikeMoreCommentCell")
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
    }
    
    //MARK: UITableView Delegate & DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return commentDic.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section) {
        case 0:
            
            let cell: PostImageCell! = tableView.dequeueReusableCell(withIdentifier: "PostImageCell") as? PostImageCell
            cell.postImg.image = postImage
            return cell

        case 1:
            
            let cell: LikeMoreCommentCell! = tableView.dequeueReusableCell(withIdentifier: "LikeMoreCommentCell") as? LikeMoreCommentCell

            if let currentPost = currentPost {
                
                if currentPost.userId != AppPrefsManager.getUserID() {
                    
                    cell.btnMore.isHidden = true
                }
                
                cell.btnLikeCount.setTitle("\(currentPost.total_likes) Likes", for: .normal)
            }
            cell.delegate = self
            
            return cell
            
        case 2:
            
            let cell: CommentCell! = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell
            print(commentDic[indexPath.row])

            let comment = commentDic[indexPath.row]
            cell.lblUsername.text = comment["username"] ?? ""
            cell.lblComment.text = comment["comment"] ?? ""

            return cell
            
        default:
            
            let cell = UITableViewCell.init()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.commentTxt.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return view.frame.width
        case 1:
            return 50
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    
    //MARK - Like Post
    func likePost(postId: String, cell: LikeMoreCommentCell) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {
            
            let ref = AppConstant.FirebaseConstants.postRef.child(postId).child("total_likes")
            
            ref.runTransactionBlock({ (currentData: MutableData!) -> TransactionResult in
                
                var value = currentData.value as? Int
                
                if value == nil {
                    value = 0
                }
                
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            }) { (error, commited, snapshot) in
                
                if commited {
                    
                    ref.observeSingleEvent(of: .value, with: { (snap) in
                        
                        print(snap.value!)
                        if snap.exists() {
                            
                            let whoLikesRef = AppConstant.FirebaseConstants.postRef.child(postId).child("user_who_liked").child(AppPrefsManager.getUserID())
                            whoLikesRef.setValue(AppPrefsManager.getUserID())
                            
                            let userRef = AppConstant.FirebaseConstants.userRef.child(AppPrefsManager.getUserID()).child("liked_posts").child(postId)
                            userRef.setValue(postId)
                        }
                        else
                        {
                            print("does not exists")
                        }
                    })
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    //MARK - Unlike Post
    func unlikePost(postId: String, cell: LikeMoreCommentCell) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {
            
            let ref = AppConstant.FirebaseConstants.postRef.child(postId).child("total_likes")
            
            ref.runTransactionBlock({ (currentData: MutableData!) -> TransactionResult in
                
                var value = currentData.value as? Int
                
                if value == nil {
                    value = 0
                }
                
                currentData.value = value! - 1
                return TransactionResult.success(withValue: currentData)
            }) { (error, commited, snapshot) in
                
                if commited {
                    
                    ref.observeSingleEvent(of: .value, with: { (snap) in
                        
                        print(snap.value!)
                        if snap.exists() {
                            
                            let whoLikesRef = AppConstant.FirebaseConstants.postRef.child(postId).child("user_who_liked")
                            whoLikesRef.child(AppPrefsManager.getUserID()).removeValue()
                            
                            let userRef = AppConstant.FirebaseConstants.userRef.child(AppPrefsManager.getUserID()).child("liked_posts").child(postId)
                            userRef.removeValue()
                        }
                        else
                        {
                            print("does not exists")
                        }
                    })
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    //MARK - Delete Post
    func deletePost(postId: String, imgUrl: String) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {

            if postId != "" {
                
                let postRef = AppConstant.FirebaseConstants.postRef.child(postId)
                
                postRef.removeValue { (error, _ ) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                        if imgUrl != "" {
                            
                            let storageRef = Storage.storage().reference(forURL: imgUrl)
                            
                            storageRef.delete { (error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    print("post deleted")
                                    //self.animator.stopAnimating()
                                    
                                    ToastMessage.show(message: "Post hase been deleted", controller: self)
                                    UIView.animate(withDuration: 0.2, delay: 0.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                        
                                        self.navigationController?.popViewController(animated: true)
                                    }, completion: nil)
                                }
                            }
                        }
                    }
                }
            } else {
                print("There is not post")
            }
        }
    }
    
    //MARK: UITextField Delegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == commentTxt {
            
            if (commentTxt.text?.count)! > 0 {
                isSendComment = true
            } else {
                isSendComment = false
            }
            commentTxt.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isSendComment == true {
            print("sent")
            
            sendComment()
        } else {
            print("not sent")
        }
    }
    
    //MARK: SendComment
    func sendComment() {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)

        } else {
            
            if let currentPost = currentPost {
                
                let commentRef = AppConstant.FirebaseConstants.postRef.child(currentPost.postId).child("Comments")
                let commentAutoID = commentRef.childByAutoId().key
                
                let commentDic = ["comment_id" : commentAutoID,
                                  "comment" : commentTxt.text!,
                                  "user_id" : AppPrefsManager.getUserID(),
                                  "username" : AppPrefsManager.getUsername(),
                                  "created_at" : "\(Date.timeIntervalSinceReferenceDate)"]
                
                commentRef.child(commentAutoID!).setValue(commentDic)
                
                commentTxt.text = ""
            }
        }
    }
    
    //MARK: GetAllComments
    func getAllComments()  {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connet to the internet", controller: self)
            
        } else {
            
            if let currentPost = currentPost {
                
                let commentRef = AppConstant.FirebaseConstants.postRef.child(currentPost.postId).child("Comments")
                
                commentRef.queryOrdered(byChild: "created_at") .observe(.value) { (snapshot) in
                    
                    if snapshot.exists() {
                        
                        guard let snapshot = snapshot.value as? [String : Any] else {
                            return
                        }
                        
                        self.commentDic.removeAll()
                        
                        for snap in snapshot.values {
                            guard let snap = snap as? [String : Any] else {
                                
                                return
                            }
                            print(snap)
                            self.commentDic.append(snap as! [String : String])
                            
                        }
                        
                        print(self.commentDic)
                        let section = IndexSet(integer: 2)
                        self.tableView.reloadSections(section, with: .fade)
                        
                    } else {
                        
                        print("This post have no comments")
                    }
                }
            }
        }
    }
    
    //MARK: Get current user liked post
    func getCurrentUserLikedPost() {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connet to the internet", controller: self)
            
        } else {
            
            let likeRef = AppConstant.FirebaseConstants.userRef.child(AppPrefsManager.getUserID()).child("liked_posts")
            likeRef.observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.exists() {
                    
                    guard let snapshot = snapshot.value as? [String : Any] else {
                        return
                    }
                    
                    for snap in snapshot.values {
                        
                        print(snap)
                        let postId = snap as! String
                        
                        let index = IndexPath(row: 0, section: 1)
                        let cell = self.tableView.cellForRow(at: index) as! LikeMoreCommentCell
                      
                        if let currentPost = self.currentPost {
                            if postId == currentPost.postId {
                                
                                cell.btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
                                break
                            } else {
                                
                                cell.btnLike.setImage(UIImage(named: "ic_unlike"), for: .normal)
                            }
                        }
                    }
                } else {
                    
                }
            }
        }
    }
    
    func getLikeDislikeLiveValues(postID: String) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
        } else {
            
            let ref = AppConstant.FirebaseConstants.postRef.child(postID).child("total_likes")
            
            ref.observe(DataEventType.value) { (snapshot) in
                
                if snapshot.exists() {
                    
                    let index: IndexPath = IndexPath(row: 0, section: 1)
                    let cell = self.tableView.cellForRow(at: index) as! LikeMoreCommentCell
                    cell.btnLikeCount.setTitle("\(String(describing: snapshot.value!)) Likes", for: .normal)
                }
            }
        }
    }

    //MARK: Keyboard Hide and Show
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let screenHeight = UIScreen.main.bounds.size.height
            
            if screenHeight < 812 {
                
                self.bottomConstrain.constant = -(keyboardHeight - self.commentView.frame.height - 0)
            } else {
                
                self.bottomConstrain.constant = -(keyboardHeight - self.commentView.frame.height - 37)
            }

            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {

                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.bottomConstrain.constant = 0.0

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTxt.resignFirstResponder()
    }
    
    @objc func onTapTableView() {
        commentTxt.resignFirstResponder()
    }

    //MARK: Back Click
    @IBAction func onClickBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

}

extension PostDetailVC: LikeMoreCommentCellDelegate {
    func likeUnlikePic(cell: LikeMoreCommentCell) {
        
        if cell.btnLike.currentImage!.isEqual(UIImage(named: "ic_unlike")) {
            
            cell.btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
            
            if let currentPost = currentPost {
                likePost(postId: currentPost.postId, cell: cell)
            }
        } else {
            
            cell.btnLike.setImage(UIImage(named: "ic_unlike"), for: .normal)
            
            if let currentPost = currentPost {
                unlikePost(postId: currentPost.postId, cell: cell)
            }
        }
    }
    
    func moreSelection() {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this post?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            
            if let currentPost = self.currentPost {
                self.deletePost(postId: currentPost.postId, imgUrl: currentPost.imgUrl)
            }
            //self.animator.startAnimating()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true) {
            
        }
    }
    
    func addComment() {
        if commentTxt.resignFirstResponder() {
            commentTxt.becomeFirstResponder()
        } else {
            commentTxt.resignFirstResponder()
        }
    }
    
    
}

