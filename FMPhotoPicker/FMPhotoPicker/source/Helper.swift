//
//  Helper.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

class Helper: NSObject {
    static func getFullSizePhoto(by asset: PHAsset, complete: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        let pId = manager.requestImageData(for: asset, options: options) { data, _, _, info in
            guard let data = data,
                let image = UIImage(data: data)
                else {
                return complete(nil)
            }
            complete(image)
        }
//        manager.cancelImageRequest(pId)
        return pId
    }
    
    static func getPhoto(by photoAsset: PHAsset, in desireSize: CGSize, complete: @escaping (UIImage?) -> Void) -> PHImageRequestID {    
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        let manager = PHImageManager.default()
        let newSize = CGSize(width: desireSize.width,
                             height: desireSize.height)
        
        let pId = manager.requestImage(for: photoAsset, targetSize: newSize, contentMode: .aspectFill, options: options, resultHandler: { result, _ in
            complete(result)
        })
//        manager.cancelImageRequest(pId)
        return pId
    }
    
    static func attemptRequestPhotoLibAccess(dialogPresenter: UIViewController, ok: @escaping () -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            ok()
        } else {
            let requestCameraAccessRight: () -> Void = {
                let comletionHandler: (PHAuthorizationStatus) -> Void = { status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            ok()
                        } else {
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        }
                    }
                }
                
                // attempt to request access
                PHPhotoLibrary.requestAuthorization(comletionHandler)
            }
            self.showDialog(in: dialogPresenter,
                            title: "FMPhotoPicker",
                            message: "Give me permission",
                            ok: requestCameraAccessRight,
                            cancel: {})
        }
    }
    
    static func showDialog(in viewController: UIViewController,
                           title: String,
                           message: String,
                           ok: (() -> Void)?,
                           cancel: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if ok != nil {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                ok!()
                
            }))
        }
        if cancel != nil {
            alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in cancel!() }))
        }

        viewController.present(alertController, animated: true)
    }
}
