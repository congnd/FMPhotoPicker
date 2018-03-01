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
    
    let selectedColor = UIColor(red: 1, green: 81/255, blue: 81/255, alpha: 1)
    let unselectColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        name = UILabel()
        
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: 15, y: 8, width: 60, height: 60)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        
        self.addSubview(imageView)
        self.addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        name.text = "Filter"
        name.textColor = .black
        name.font = UIFont.systemFont(ofSize: 12)
    }
    
    override func prepareForReuse() {
        setDeselected()
    }
    
    public func setSelected() {
        imageView.layer.borderColor = selectedColor.cgColor
        name.textColor = selectedColor
    }
    
    public func setDeselected() {
        imageView.layer.borderColor = unselectColor.cgColor
        name.textColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
