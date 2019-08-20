//
//  CameraVC.swift
//  Cloud Camera
//
//  Created by Anjali Kevadiya on 12/24/18.
//  Copyright © 2018 Anjali Kevadiya. All rights reserved.
//

import UIKit

class CameraVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var takePhotoBtn: UIButton!
    
    var captureImage: UIImageView!
    var imgPicker: UIImagePickerController!
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Take Photo
    @IBAction func onClickTakePhoto(_ sender: UIButton) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            selectImageFrom(.photoLibrary)
            return
        }
        selectImageFrom(.camera)
    }
    
    func selectImageFrom(_ source: ImageSource) {
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        switch source {
        case .camera:
            imgPicker.sourceType = .camera
        case .photoLibrary:
            imgPicker.sourceType = .photoLibrary
        }
        present(imgPicker, animated: true, completion: nil)
    }
    
    //MARK: Upload Photo
    @IBAction func onClickUploadPhoto(_ sender: UIButton) {
        
        let photoLibraryVC = storyboard?.instantiateViewController(withIdentifier: "PhotoLibraryVC") as! PhotoLibraryVC
        self.navigationController?.pushViewController(photoLibraryVC, animated: true)
    }

    
    //MARK: UIImagePickerViewController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            
            print("Image not found!")
            return
        }
        
        let uploadPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadPhotoVC") as! UploadPhotoVC
        uploadPhotoVC.selectedImg = selectedImage
        self.navigationController?.pushViewController(uploadPhotoVC, animated: true)

        imgPicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imgPicker.dismiss(animated: true, completion: nil)
        print("Cancelled")
    }
}
