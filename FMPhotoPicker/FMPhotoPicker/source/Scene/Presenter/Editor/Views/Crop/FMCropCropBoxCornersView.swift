 //
//  FMCropCropBoxCornersView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/08.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropCropBoxCornersView: UIView {
    private let borderWidth: CGFloat = 2.0
    private let lineWidth: CGFloat = 4.0
    private let lineHeight: CGFloat = 18
    
    private let topLeftView: UIView
    private let topRightView: UIView
    
    private let rightTopView: UIView
    private let rightBottomView: UIView
    
    private let bottomRightView: UIView
    private let bottomLeftView: UIView
    
    private let leftBottomView: UIView
    private let leftTopView: UIView
    
    private let borderView: UIView
    
    override var frame: CGRect {
        didSet {
            borderView.frame = bounds
            
            topLeftView.frame.origin.x = bounds.origin.x - lineWidth + borderWidth
            topLeftView.frame.origin.y = bounds.origin.y - lineWidth + borderWidth
            
            topRightView.frame.origin.x = bounds.maxX + lineWidth - lineHeight - borderWidth
            topRightView.frame.origin.y = topLeftView.frame.origin.y
            
            rightTopView.frame.origin.x = bounds.maxX - borderWidth
            rightTopView.frame.origin.y = topRightView.frame.origin.y
            
            rightBottomView.frame.origin.x = bounds.maxX - borderWidth
            rightBottomView.frame.origin.y = bounds.maxY + lineWidth - lineHeight - borderWidth
            
            bottomRightView.frame.origin.x = topRightView.frame.origin.x
            bottomRightView.frame.origin.y = bounds.maxY - borderWidth
            
            bottomLeftView.frame.origin.x = bounds.origin.x - lineWidth + borderWidth
            bottomLeftView.frame.origin.y = bottomRightView.frame.origin.y
            
            leftBottomView.frame.origin.x = topLeftView.frame.origin.x
            leftBottomView.frame.origin.y = rightBottomView.frame.origin.y
            
            leftTopView.frame.origin = topLeftView.frame.origin
        }
    }
    
    init() {
        topLeftView = UIView(frame: CGRect(x: 0, y: 0, width: lineHeight, height: lineWidth))
        topRightView = UIView(frame: CGRect(x: 0, y: 0, width: lineHeight, height: lineWidth))
        
        rightTopView = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight))
        rightBottomView = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight))
        
        bottomRightView = UIView(frame: CGRect(x: 0, y: 0, width: lineHeight, height: lineWidth))
        bottomLeftView = UIView(frame: CGRect(x: 0, y: 0, width: lineHeight, height: lineWidth))
        
        leftBottomView = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight))
        leftTopView = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight))
        
        borderView = UIView(frame: .zero)
        
        super.init(frame: .zero)
        
        borderView.layer.borderWidth = borderWidth
        borderView.layer.borderColor = UIColor.white.cgColor
        
        topLeftView.backgroundColor = kRedColor
        topRightView.backgroundColor = kRedColor
        
        rightTopView.backgroundColor = kRedColor
        rightBottomView.backgroundColor = kRedColor
        
        bottomRightView.backgroundColor = kRedColor
        bottomLeftView.backgroundColor = kRedColor
        
        leftBottomView.backgroundColor = kRedColor
        leftTopView.backgroundColor = kRedColor
        
        addSubview(borderView)
        
        addSubview(topLeftView)
        addSubview(topRightView)
        
        addSubview(rightTopView)
        addSubview(rightBottomView)
        
        addSubview(bottomRightView)
        addSubview(bottomLeftView)
        
        addSubview(leftBottomView)
        addSubview(leftTopView)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
