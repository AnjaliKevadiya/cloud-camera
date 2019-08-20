//
//  PhotoLibraryVC.swift
//  Cloud Camera
//
//  Created by Anjali Kevadiya on 1/2/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var images = [PHAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        checkPhotoLibraryAccessPermission()
        self.collectionView.reloadData()

    }
    
    func checkPhotoLibraryAccessPermission()  {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            self.getImages()
        case .denied, .restricted :
            print("You denied the permission.")
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { status in
                
                switch status {
                case .authorized:
                    self.getImages()
                case .denied, .restricted:
                    print("You denied the permission.")
                case .notDetermined: break
                }
            }
        }
    }
    
    func getImages() {
        
        //        let videoAssets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        //        videoAssets.enumerateObjects { (object, count, stop) in
        //            self.images.append(object)
        //        }
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            self.images.append(object)
        })
        
        self.images.reverse()
        
    }

    //MARK: UICollectionView Delegate & DataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCVCell", for: indexPath as IndexPath) as! HomeCVCell
        
        let asset = images[indexPath.row]
        
        let manager = PHImageManager.default()
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.width), contentMode: .aspectFill, options: nil) { (result, _) in
            
            if result != nil {
                cell.thumbNail.image = result
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! HomeCVCell
                
        let uploadPhotoVC = storyboard?.instantiateViewController(withIdentifier: "UploadPhotoVC") as! UploadPhotoVC
        uploadPhotoVC.selectedImg = cell.thumbNail.image
        
        self.navigationController?.pushViewController(uploadPhotoVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        
        if AppUtils.DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

