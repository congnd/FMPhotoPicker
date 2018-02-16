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
        options.deliveryMode = .opportunistic
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
    
    static func getAssets(allowMediaTypes: [FMMediaType]) -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        
        // Default sort is modificationDate
        // fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchOptions.predicate = NSPredicate(format: "mediaType IN %@", allowMediaTypes.map( { $0.value() }))
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        guard fetchResult.count > 0 else { return [] }
        
        var photoAssets = [PHAsset]()
        fetchResult.enumerateObjects() { asset, index, _ in
            photoAssets.append(asset)
        }
        
        return photoAssets
    }
    
    static func canAccessPhotoLib() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    static func openIphoneSetting() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    static func requestAuthorizationForPhotoAccess(authorized: @escaping () -> Void, rejected: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    authorized()
                } else {
                    rejected()
                }
            }
        }
    }
    
    static func showDialog(in viewController: UIViewController,
                           ok: (() -> Void)? = nil,
                           cancel: (() -> Void)? = nil,
                           title: String = "FMPhotoPicker",
                           message: String = "FMPhotoPicker want to access Photo Library") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in ok?() }))
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in cancel?() }))

        viewController.present(alertController, animated: true)
    }
}
