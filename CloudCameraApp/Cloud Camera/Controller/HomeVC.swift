//
//  HomeVC.swift
//  Cloud Camera
//
//  Created by Anjali Kevadiya on 12/24/18.
//  Copyright © 2018 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AlamofireImage

class HomeVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewNoPost: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var postDic = [Post]()
    var isFrom: String!
    
    var postsRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        activityIndicator.stopAnimating()
        viewNoPost.isHidden = true
        postDic.removeAll()
        collectionView.delegate = self
        collectionView.dataSource = self
        getAllPosts()
    }
    
    //MARK: UICollectionView Delegate & Datasource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDic.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCVCell", for: indexPath) as! HomeCVCell
        
        let currentPost = postDic[indexPath.row]
        
        let imgUrl = URL(string: currentPost.imgUrl)
        cell.thumbNail!.af_setImage(withURL: imgUrl!)
        cell.thumbNail.downloaded(from: currentPost.imgUrl, contentMode:UIView.ContentMode.scaleAspectFill)
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! HomeCVCell
        
        let currentPost = postDic[indexPath.row]
        
        let postDetailVC = storyboard?.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
        
        if cell.thumbNail.image != nil {
            
            postDetailVC.postDic = [currentPost]
            postDetailVC.postImage = cell.thumbNail.image
        }
        else
        {
            //send the static image
        }
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        
        if AppUtils.DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width / 3 - 1, height: width / 3 - 1)
        } else {
            return CGSize(width: width / 6 - 1, height: width / 6 - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: Get Post from the Database
    func getAllPosts() {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connet to the internet", controller: self)

        } else {
            
            activityIndicator.startAnimating()
            collectionView.isUserInteractionEnabled = false
            
            self.postsRef = AppConstant.FirebaseConstants.postRef
            self.postsRef.observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.exists() {
                    
                    guard let snapshot = snapshot.value as? [String : Any] else {
                        return
                    }
                    
                    print(snapshot)
                    for snap in snapshot.values {
                        guard let snap = snap as? [String: Any] else { return }
                        
                        let post = Post(postId: snap["post_id"] as! String,
                                        userId: snap["user_id"] as! String,
                                        username: snap["username"] as! String,
                                        imgUrl: snap["image_url"] as! String,
                                        caption: snap["caption"] as! String,
                                        created_at: snap["created_at"] as! String,
                                        total_likes: snap["total_likes"] as! NSNumber)
                        self.postDic.append(post)
                    }
                    self.viewNoPost.isHidden = true
                    self.collectionView.reloadData()
                    
                } else {
                    print("There is no posts")
                    self.viewNoPost.isHidden = false
                }
                self.activityIndicator.stopAnimating()
                self.collectionView.isUserInteractionEnabled = true
            }
        }
    }
    
    @IBAction func onClickSignOutButton(_ sender: UIButton) {
        

        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                
                if !AppPrefsManager.getUserID().isEmpty{
                    AppPrefsManager.deleteUserID()
                }
                if !AppPrefsManager.getUsername().isEmpty {
                    AppPrefsManager.deleteUsername()
                }
                
                let loginNavController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = loginNavController
                
            } catch let error {
                print(error)
            }
        }
        
    }
}

extension UIImageView {
    
    func load(url: URL) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

