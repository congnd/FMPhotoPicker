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
        
        editButton.addTarget(self, action: #selector(editButtonTarget), for: .touchUpInside)
        
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
    }
    
    @objc private func editButtonTarget() {
        onTapEditButton?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
