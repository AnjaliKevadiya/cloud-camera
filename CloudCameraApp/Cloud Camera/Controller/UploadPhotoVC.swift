//
//  UploadPhotoVC.swift
//  Cloud Camera
//
//  Created by Anjali Kevadiya on 1/7/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import IQKeyboardManagerSwift

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class UploadPhotoVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var captionTxt: UITextField!
    @IBOutlet weak var postImgView:UIImageView!
    @IBOutlet weak var animator:UIActivityIndicatorView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var captionView: UIView!
    
    var selectedImg: UIImage!
    var postRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        postImgView.image = selectedImg
        animator.stopAnimating()
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Upload Click
    @IBAction func onClickUpload(_ sender: UIButton) {
        
        if AppDelegate.isNetworkReachability() == false {
            
            ToastMessage.show(message: "You are offline. connect to the internet", controller: self)
            
        } else {
            
            if captionTxt.text == "" {
                
                ToastMessage.show(message: "Caption can not be empty.", controller: self)
            } else {
                
                //animator start animating
                animator.startAnimating()
                captionTxt.isUserInteractionEnabled = false
                
                let uploadingImage: UIImage = postImgView.image!
                
                let resizedImg = uploadingImage.resized(toWidth: 1000)
                //        let compressedImg = resizedImg!.resized(withPercentage: 0.5)
                
                guard let imageData = resizedImg!.jpegData(compressionQuality: 0.2) else { return }
                
                let imagePath = "\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpeg"
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let imagesFolderRef = AppConstant.FirebaseConstants.postImagesRef.child(imagePath)
                
                imagesFolderRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error)")
                        self.animator.stopAnimating()
                        return
                    }
                    else
                    {
                        self.uploadSuccess(imagesFolderRef, storagePath: imagePath)
                    }
                }
            }
        }
    }
    
    func uploadSuccess(_ storageRef: StorageReference, storagePath: String) {
        print("Upload Succeeded!")
        storageRef.downloadURL { (url, error) in
            
            if let error = error {
                print("Error getting download URL: \(error)")
                return
            }
            else {
                
                //stop animator
                self.animator.stopAnimating()
                ToastMessage.show(message: "Post has been uploaded.", controller: self)
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    //navigate to HomeVC
                    let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
                    tabBarVC.selectedIndex = 0
                })
                
                self.navigationController?.popToRootViewController(animated: true)
                
                let downloadableURL = url?.absoluteString
                
                let postAutoID = AppConstant.FirebaseConstants.postRef.childByAutoId().key
                
                let postDic = ["post_id": postAutoID!,
                               "user_id": AppPrefsManager.getUserID(),
                               "username" : AppPrefsManager.getUsername(),
                               "image_url": downloadableURL as Any,
                               "caption": self.captionTxt.text!,
                               "created_at": "\(Date.timeIntervalSinceReferenceDate)",
                               "total_likes": 0] as [String : Any]
                
                AppConstant.FirebaseConstants.postRef.child(postAutoID!).setValue(postDic)
                
                self.captionTxt.text = ""
            }
        }
    }
    
    //MARK: Back Click
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == captionTxt {
            captionTxt.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Keyboard Hide and Show
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let screenHeight = UIScreen.main.bounds.size.height
        if screenHeight < 812 {
            
            self.topConstraint.constant = -(self.captionView.frame.height * 2.07)
            
            UIView.animate(withDuration: 0.7, delay: 0.07, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.topConstraint.constant = 2
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        captionTxt.resignFirstResponder()
    }
    
}
