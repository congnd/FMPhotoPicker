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
    
    private var selectCircleView: UIView
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        name = UILabel()
        selectCircleView = UIView()
        
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: (frame.width - 36) / 2, y: 12, width: 36, height: 36)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        selectCircleView.frame = imageView.frame.insetBy(dx: -3, dy: -3)
        selectCircleView.layer.cornerRadius = selectCircleView.frame.width / 2
        selectCircleView.layer.borderWidth = 2
        selectCircleView.layer.borderColor = kRedColor.cgColor
        
        // hide selectCircleView by default
        selectCircleView.isHidden = true
        
        self.addSubview(selectCircleView)
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
        selectCircleView.isHidden = false
        name.textColor = kRedColor
    }
    
    public func setDeselected() {
        selectCircleView.isHidden = true
        name.textColor = kGrayColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
