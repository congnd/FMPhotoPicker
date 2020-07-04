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
    
    
    weak var cellFilterContainer: UIView!
    weak var imageView: UIImageView!
    weak var selectButton: UIButton!
    weak var selectedIndex: UILabel!
    weak var videoInfoView: UIView!
    weak var videoLengthLabel: UILabel!
    weak var editedMarkImageView: UIImageView!
    weak var editedMarkImageViewTopConstraint: NSLayoutConstraint!
    
    private weak var photoAsset: FMPhotoAsset?
    
    public var onTapSelect = {}
    
    private var selectMode: FMSelectMode!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.clipsToBounds = true
        
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])
        
        let videoInfoView = UIView()
        self.videoInfoView = videoInfoView
        videoInfoView.isHidden = true
        
        contentView.addSubview(videoInfoView)
        videoInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoInfoView.heightAnchor.constraint(equalToConstant: 24),
            videoInfoView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            videoInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoInfoView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])
        
        let videoIcon = UIImageView()
        videoIcon.contentMode = .scaleAspectFill
        videoIcon.image = UIImage(named: "video_icon", in: .current, compatibleWith: nil)
        
        videoInfoView.addSubview(videoIcon)
        videoIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoIcon.heightAnchor.constraint(equalToConstant: 8),
            videoIcon.widthAnchor.constraint(equalToConstant: 17),
            videoIcon.leftAnchor.constraint(equalTo: videoInfoView.leftAnchor, constant: 8),
            videoIcon.centerYAnchor.constraint(equalTo: videoInfoView.centerYAnchor)
        ])
        
        let videoLengthLabel = UILabel()
        self.videoLengthLabel = videoLengthLabel
        videoLengthLabel.font = .systemFont(ofSize: 12, weight: .medium)
        videoLengthLabel.textColor = .white
        
        videoInfoView.addSubview(videoLengthLabel)
        videoLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoLengthLabel.rightAnchor.constraint(equalTo: videoInfoView.rightAnchor, constant: -8),
            videoLengthLabel.centerYAnchor.constraint(equalTo: videoInfoView.centerYAnchor)
        ])
        
        let cellFilterContainer = UIView()
        self.cellFilterContainer = cellFilterContainer
        cellFilterContainer.layer.borderColor = kRedColor.cgColor
        cellFilterContainer.layer.borderWidth = 2
        cellFilterContainer.isHidden = true
        
        contentView.addSubview(cellFilterContainer)
        cellFilterContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellFilterContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellFilterContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cellFilterContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellFilterContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])
        
        let selectButton = UIButton()
        self.selectButton = selectButton
        selectButton.addTarget(self, action: #selector(onTapSelects(_:)), for: .touchUpInside)
        
        contentView.addSubview(selectButton)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            selectButton.heightAnchor.constraint(equalToConstant: 40),
            selectButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        
        let selectedIndex = UILabel()
        self.selectedIndex = selectedIndex
        selectedIndex.font = .systemFont(ofSize: 15)
        selectedIndex.textColor = .white
        
        contentView.addSubview(selectedIndex)
        selectedIndex.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedIndex.centerXAnchor.constraint(equalTo: selectButton.centerXAnchor),
            selectedIndex.centerYAnchor.constraint(equalTo: selectButton.centerYAnchor),
        ])
        
        let editedMarkImageView = UIImageView()
        self.editedMarkImageView = editedMarkImageView
        editedMarkImageView.image = UIImage(named: "icon_edited", in: .current, compatibleWith: nil)
        editedMarkImageViewTopConstraint = editedMarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35)
        
        contentView.addSubview(editedMarkImageView)
        editedMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editedMarkImageViewTopConstraint,
            editedMarkImageView.centerXAnchor.constraint(equalTo: selectButton.centerXAnchor),
            editedMarkImageView.heightAnchor.constraint(equalToConstant: 20),
            editedMarkImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
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
            self.editedMarkImageViewTopConstraint?.constant = 10
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
                self.selectButton.setImage(UIImage(named: "check_on", in: .current, compatibleWith: nil), for: .normal)
            } else {
                self.selectedIndex.isHidden = true
                self.selectButton.setImage(UIImage(named: "single_check_on", in: .current, compatibleWith: nil), for: .normal)
            }
            self.cellFilterContainer.isHidden = false
        } else {
            self.selectedIndex.isHidden = true
            self.cellFilterContainer.isHidden = true
            self.selectButton.setImage(UIImage(named: "check_off", in: .current, compatibleWith: nil), for: .normal)
        }
    }
}
