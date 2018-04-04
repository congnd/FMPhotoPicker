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
    @IBOutlet weak var editedMarkImageView: UIImageView!
    @IBOutlet weak var editedMarkImageViewTopConstraint: NSLayoutConstraint!
    
    private weak var photoAsset: FMPhotoAsset?
    
    public var onTapSelect = {}
    
    private var selectMode: FMSelectMode!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellFilterContainer.layer.borderColor = kRedColor.cgColor
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
        
        if selectMode == .single {
            self.selectedIndex.isHidden = true
            self.selectButton.isHidden = true
            self.editedMarkImageViewTopConstraint.constant = 10
        }
        
        self.photoAsset = photoAsset

        photoAsset.requestThumb() { image in
            self.imageView.image = image
        }
        
        photoAsset.thumbChanged = { [weak self, weak photoAsset] image in
            guard let strongSelf = self, let strongPhotoAsset = photoAsset else { return }
            strongSelf.imageView.image = image
            strongSelf.editedMarkImageView.isHidden = !strongPhotoAsset.isEdited()
        }
        
        if photoAsset.mediaType == .video {
            self.videoInfoView.isHidden = false
            self.videoLengthLabel.text = photoAsset.asset?.duration.stringTime
        }
        
        self.editedMarkImageView.isHidden = !photoAsset.isEdited()
        
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
