//
//  FMPhotoPickerImageCollectionViewCell.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

class FMPhotoPickerImageCollectionViewCell: UICollectionViewCell {
    static let scale: CGFloat = 3
    static let reuseId = String(describing: FMPhotoPickerImageCollectionViewCell.self)
    
    
    @IBOutlet weak var cellFilterContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectedIndex: UILabel!
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoLengthLabel: UILabel!
    
    private weak var photoAsset: FMPhotoAsset?
    
    public var onTapSelect = {}
    
    private var selectMode: FMSelectMode!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellFilterContainer.layer.borderColor = UIColor(red: 255/255, green: 81/255, blue: 81/255, alpha: 1).cgColor
        self.cellFilterContainer.layer.borderWidth = 2
        self.cellFilterContainer.isHidden = true
        self.videoInfoView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.image = nil
        self.videoInfoView.isHidden = true
        
        self.photoAsset?.cancelAllRequest()
    }
    
    public func loadView(photoAsset: FMPhotoAsset, selectMode: FMSelectMode, selectedIndex: Int?) {
        self.selectMode = selectMode
        
        self.photoAsset = photoAsset

        photoAsset.requestThumb() { image in
            self.imageView.image = image
        }
        
        if photoAsset.mediaType == .video {
            self.videoInfoView.isHidden = false
            self.videoLengthLabel.text = photoAsset.asset.duration.stringTime
        }
        
        self.performSelectionAnimation(selectedIndex: selectedIndex)
    }
    @IBAction func onTapSelects(_ sender: Any) {
        self.onTapSelect()
    }
    
    func performSelectionAnimation(selectedIndex: Int?) {
        if let selectedIndex = selectedIndex {
            if self.selectMode == .multiple {
                self.selectedIndex.isHidden = false
                self.selectedIndex.text = "\(selectedIndex + 1)"
                self.selectButton.setImage(UIImage(named: "check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            } else {
                self.selectedIndex.isHidden = true
                self.selectButton.setImage(UIImage(named: "single_check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            }
            self.cellFilterContainer.isHidden = false
        } else {
            self.selectedIndex.isHidden = true
            self.cellFilterContainer.isHidden = true
            self.selectButton.setImage(UIImage(named: "check_off", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        }
    }
}
