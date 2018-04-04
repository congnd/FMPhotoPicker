//
//  FMPhotosDataSource.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/01.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import Photos

class FMPhotosDataSource {
    public private(set) var photoAssets: [FMPhotoAsset]
    private var selectedPhotoIndexes: [Int]
    
    init(photoAssets: [FMPhotoAsset]) {
        self.photoAssets = photoAssets
        self.selectedPhotoIndexes = []
    }
    
    public func setSeletedForPhoto(atIndex index: Int) {
        if self.selectedPhotoIndexes.index(where: { $0 == index }) == nil {
            self.selectedPhotoIndexes.append(index)
        }
    }
    
    public func unsetSeclectedForPhoto(atIndex index: Int) {
        if let indexInSelectedIndex = self.selectedPhotoIndexes.index(where: { $0 == index }) {
            self.selectedPhotoIndexes.remove(at: indexInSelectedIndex)
        }
    }
    
    public func selectedIndexOfPhoto(atIndex index: Int) -> Int? {
        return self.selectedPhotoIndexes.index(where: { $0 == index })
    }
    
    public func numberOfSelectedPhoto() -> Int {
        return self.selectedPhotoIndexes.count
    }
    
    public func mediaTypeForPhoto(atIndex index: Int) -> FMMediaType? {
        return self.photo(atIndex: index)?.mediaType
    }
    
    public func countSelectedPhoto(byType: FMMediaType) -> Int {
        return self.getSelectedPhotos().filter { $0.mediaType == byType }.count
    }
    
    public func affectedSelectedIndexs(changedIndex: Int) -> [Int] {
        return Array(self.selectedPhotoIndexes[changedIndex...])
    }

    public func getSelectedPhotos() -> [FMPhotoAsset] {
        var result = [FMPhotoAsset]()
        self.selectedPhotoIndexes.forEach {
            if let photo = self.photo(atIndex: $0) {
                result.append(photo)
            }
        }
        return result
    }
    
    public var numberOfPhotos: Int {
        return self.photoAssets.count
    }
    
    public func photo(atIndex index: Int) -> FMPhotoAsset? {
        guard index < self.photoAssets.count, index >= 0 else { return nil }
        return self.photoAssets[index]
    }
    
    public func index(ofPhoto photo: FMPhotoAsset) -> Int? {
        return self.photoAssets.index(where: { $0 === photo })
    }
    
    public func contains(photo: FMPhotoAsset) -> Bool {
        return self.index(ofPhoto: photo) != nil
    }
    
    public func delete(photo: FMPhotoAsset) {
        if let index = self.index(ofPhoto: photo) {
            self.photoAssets.remove(at: index)
        }
    }
    
}
