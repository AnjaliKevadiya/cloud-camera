//
//  AppUtils.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/8/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

class AppUtils: NSObject {

    class func setCornerRadiusForView(view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
    }
    
    class func setCornerRadiusForButton(button: UIButton, radius: CGFloat) {
        button.layer.cornerRadius = radius
    }
    
    class func clearTextField(textFields: [UITextField]) {
        
        for textfield in textFields {
            textfield.text = ""
        }
    }

    struct DeviceInfo {
        struct Orientation {
            
            static var isLandscape: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isLandscape
                        : UIApplication.shared.statusBarOrientation.isLandscape
                }
            }
            
            static var isPortrait: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isPortrait
                        : UIApplication.shared.statusBarOrientation.isPortrait
                }
            }
        }
    }
}
