//
//  Helper.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class Helper: NSObject {
    static func generateVideoFrames(from phAsset: PHAsset, numberOfFrames: Int = 9, completion: @escaping ([CGImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let multiTask = DispatchGroup()
            var asset: AVAsset?
            
            multiTask.enter()
            Helper.requestAVAsset(asset: phAsset, complete: { avAsset in
                asset = avAsset
                multiTask.leave()
            })
            multiTask.wait()
            
            guard let avAsset = asset else { return completion([]) }
            
            let durationInSeconds = CMTimeGetSeconds(avAsset.duration)
            
            var times = [CMTime]()
            for i in 0..<numberOfFrames {
                times.append(CMTimeMakeWithSeconds(durationInSeconds / Double(numberOfFrames) * Double(i), 1000))
            }
            
            let generator = AVAssetImageGenerator(asset: avAsset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 100, height: 100)
            
            var cgImages = [CGImage]()
            times.forEach {
                guard let cgImage = try? generator.copyCGImage(at: $0, actualTime: nil) else { return }
                cgImages.append(cgImage)
            }
            
            DispatchQueue.main.async {
                completion(cgImages)
            }
        }
    }
    
    static func requestAVAsset(asset: PHAsset, complete: @escaping (AVAsset?) -> Void) {
        guard asset.mediaType == .video else { return complete(nil) }
        
        PHImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, _, _) in
            DispatchQueue.main.async {
                complete(asset)
            }
        }
    }
    
    static func requestVideoURL(forAsset asset: PHAsset, complete: @escaping (URL?) -> Void) {
        guard asset.mediaType == .video else { return complete(nil) }
        
        PHImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, _, _) in
            // AVAsset has two sub classes: AVComposition and AVAssetURL
            // AVComposition for slow motion video
            // AVAssetURL for normal videos
            
            // For slow motion video checking for AVCompostion
            // Creating an exporter to write the video into local file path and using the same to play/upload
            
            if asset!.isKind(of: AVComposition.self){
                let avCompositionAsset = asset as! AVComposition
                if avCompositionAsset.tracks.count > 1{
                    let exporter = AVAssetExportSession(asset: avCompositionAsset, presetName: AVAssetExportPresetHighestQuality)
                    exporter!.outputURL = self.fetchOutputURL()
                    exporter!.outputFileType = .mp4
                    exporter!.shouldOptimizeForNetworkUse = true
                    exporter!.exportAsynchronously {
                        let url = exporter!.outputURL
                        DispatchQueue.main.async {
                            complete(url)
                        }
                    }
                }
            } else {
                // Normal video, are stored as AVAssetURL
                let url = (asset as! AVURLAsset).url
                DispatchQueue.main.async {
                    complete(url)
                }
            }
        }
    }
    
    static func fetchOutputURL() -> URL{
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentDirectory.appendingPathComponent("test.mp4")
        return path
    }
    
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
        
        let pId = manager.requestImage(for: photoAsset, targetSize: newSize, contentMode: .aspectFit, options: options, resultHandler: { result, _ in
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
