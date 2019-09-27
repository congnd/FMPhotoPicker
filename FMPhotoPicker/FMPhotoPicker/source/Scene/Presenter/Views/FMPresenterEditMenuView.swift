//
//  FMPresenterEditMenuView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMPresenterEditMenuView: UIView {
    private let editButton: UIButton
    
    public var onTapEditButton: (() -> Void)?
    
    init(config: FMPhotoPickerConfig) {
        editButton = UIButton()
        
        super.init(frame: .zero)
        
        self.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        editButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        editButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        // editButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        editButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        editButton.setTitleColor(.black, for: .normal)
        editButton.setTitle(config.strings["present_button_edit_image"], for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: config.titleFontSize, weight: .bold)
        
        editButton.addTarget(self, action: #selector(editButtonTarget), for: .touchUpInside)
        
        // top border view
        let topBorder = UIView(frame: .zero)
        topBorder.backgroundColor = kBorderColor
        addSubview(topBorder)
        
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        topBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        topBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        self.backgroundColor = kTransparentBackgroundColor
    }
    
    @objc private func editButtonTarget() {
        onTapEditButton?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
