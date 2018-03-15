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
    
    init() {
        editButton = UIButton()
        
        super.init(frame: .zero)
        
        self.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        editButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        editButton.setTitleColor(.black, for: .normal)
        editButton.setTitle("編集", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        editButton.addTarget(self, action: #selector(editButtonTarget), for: .touchUpInside)
        
        self.backgroundColor = kTransparentBackgroundColor
    }
    
    @objc private func editButtonTarget() {
        onTapEditButton?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
