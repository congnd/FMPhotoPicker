//
//  FMFilterCell.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMFilterCell: UICollectionViewCell {
    static let reussId = String(describing: self)
    public var imageView: UIImageView
    public var name: UILabel
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        name = UILabel()
        
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: (frame.width - 36) / 2, y: 12, width: 36, height: 36)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = kRedColor.cgColor
        
        self.addSubview(imageView)
        self.addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        name.text = "Filter"
        name.textColor = kGrayColor
        name.font = UIFont.systemFont(ofSize: 8)
    }
    
    override func prepareForReuse() {
        setDeselected()
    }
    
    public func setSelected() {
        imageView.layer.borderWidth = 2
        name.textColor = kRedColor
    }
    
    public func setDeselected() {
        imageView.layer.borderWidth = 0
        name.textColor = kGrayColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
