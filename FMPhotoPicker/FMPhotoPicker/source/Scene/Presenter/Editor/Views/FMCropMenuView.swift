//
//  FMCropMenuView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMCropControl {
    case resetAll
    case resetFrameWithoutChangeRatio
    case rotate
    
    func name(from stringConfig: [String: String]) -> String {
        switch self {
        case .resetFrameWithoutChangeRatio: return stringConfig["editor_menu_crop_button_reset"]!
        case .resetAll: return stringConfig["editor_menu_crop_button_reset"]!
        case .rotate: return stringConfig["editor_menu_crop_button_rotate"]!
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .resetAll, .resetFrameWithoutChangeRatio:
            return UIImage(named: "icon_crop_reset", in: .current, compatibleWith: nil)
        case .rotate:
            return UIImage(named: "icon_crop_rotation", in: .current, compatibleWith: nil)
        }
    }
}

class FMCropMenuView: UIView {
    private let collectionView: UICollectionView
    private let menuItems: [FMCropControl]
    private let cropItems: [FMCroppable]
    
    public var didSelectCrop: (FMCroppable) -> Void = { _ in }
    public var didReceiveCropControl: (FMCropControl) -> Void = { _ in }
    
    private var selectedCrop: FMCroppable? {
        didSet {
            if let selectedCrop = selectedCrop {
                didSelectCrop(selectedCrop)
            }
        }
    }
    
    private var config: FMPhotoPickerConfig
    
    init(appliedCrop: FMCroppable?, availableCrops: [FMCroppable], config: FMPhotoPickerConfig) {
        selectedCrop = appliedCrop
        self.config = config
        
        var tAvailableCrops = availableCrops
        tAvailableCrops = tAvailableCrops.count == 0 ? kDefaultAvailableCrops : tAvailableCrops
        
        // if the force crop mode is enabled
        // then only the first crop type in the avaiableCrops will be used
        if config.forceCropEnabled {
            tAvailableCrops = [tAvailableCrops.first!]
        }
        
        cropItems = tAvailableCrops
        
        if config.forceCropEnabled {
            menuItems = [.resetFrameWithoutChangeRatio]
        } else {
            menuItems = [.resetAll]
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 64)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        collectionView.register(FMCropCell.classForCoder(), forCellWithReuseIdentifier: FMCropCell.reussId)
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 14,bottom: 0,right: 14)
    
        self.backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }
    
    func insert(toView parentView: UIView) {
        parentView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FMCropMenuView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return menuItems.count }
        if section == 1 { return cropItems.count }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMCropCell.reussId, for: indexPath) as? FMCropCell
            else { return UICollectionViewCell() }
        
        if indexPath.section == 0 {
            // menu items
            cell.name.text = menuItems[indexPath.row].name(from: config.strings)
            cell.imageView.image = menuItems[indexPath.row].icon()
        } else if indexPath.section == 1 {
            // crop items
            let cropItem = cropItems[indexPath.row]
            cell.name.text = cropItem.name(strings: config.strings)
            cell.imageView.image = cropItem.icon()
            
            if selectedCrop?.identifier() == cropItem.identifier() {
                cell.setSelected()
            }
        }
        
        return cell
    }
}
extension FMCropMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selectedCropControl = menuItems[indexPath.row]
            
            switch selectedCropControl {
            case .resetAll:
                selectedCrop = kDefaultCrop
                collectionView.reloadData()
            default: break
            }
            
            didReceiveCropControl(selectedCropControl)
        } else if indexPath.section == 1 {
            if let cell = collectionView.cellForItem(at: indexPath) as? FMCropCell {
                let prevCropItem = selectedCrop
                selectedCrop = cropItems[indexPath.row]
                cell.setSelected()
                
                if let prevCropItem = prevCropItem,
                    let prevRow = cropItems.firstIndex(where: { $0.identifier() == prevCropItem.identifier() }) {
                    collectionView.reloadItems(at: [IndexPath(row: prevRow, section: 1)])
                }
            }
        }
    }
}
