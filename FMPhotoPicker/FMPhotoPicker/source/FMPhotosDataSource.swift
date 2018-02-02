//
//  FMPhotosDataSource.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/01.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation

public struct FMPhotosDataSource {
    public private(set) var photos = [FMPhotoAsset]()
    
    public var numberOfPhotos: Int {
        return self.photos.count
    }
    
    public func photo(atIndex index: Int) -> FMPhotoAsset? {
        guard index < self.photos.count, index >= 0 else { return nil }
        return photos[index]
    }
    
    public func index(ofPhoto photo: FMPhotoAsset) -> Int? {
        return self.photos.index(where: { $0 === photo })
    }
    
    public func contains(photo: FMPhotoAsset) -> Bool {
        return self.index(ofPhoto: photo) != nil
    }
    
    public mutating func delete(photo: FMPhotoAsset) {
        if let index = self.index(ofPhoto: photo) {
            photos.remove(at: index)
        }
    }
    
}
