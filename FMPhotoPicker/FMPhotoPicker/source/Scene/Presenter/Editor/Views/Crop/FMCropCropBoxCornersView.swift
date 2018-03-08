 //
//  FMCropCropBoxCornersView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/08.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropCropBoxCornersView: UIView {
    private let lineWidth: CGFloat = 2.5
    private let lineHeight: CGFloat = 25.0
    private let color = UIColor(red: 1, green: 81/255, blue: 81/255, alpha: 1)
    
    private let topLeftView: UIView
    private let topRightView: UIView
    
    private let rightTopView: UIView
    private let rightBottomView: UIView
    
    private let bottomRightView: UIView
    private let bottomLeftView: UIView
    
    private let leftBottomView: UIView
    private let leftTopView: UIView
    
    override var frame: CGRect {
        didSet {
            topLeftView.frame.origin.x = bounds.origin.x - lineWidth
            topLeftView.frame.origin.y = bounds.origin.y - lineWidth
            
            topRightView.frame.origin.x = bounds.maxX + lineWidth - lineHeight
            topRightView.frame.origin.y = topLeftView.frame.origin.y
            
            rightTopView.frame.origin.x = bounds.maxX
            rightTopView.frame.origin.y = topRightView.frame.origin.y
            
            rightBottomView.frame.origin.x = bounds.maxX
            rightBottomView.frame.origin.y = bounds.maxY + lineWidth - lineHeight
            
            bottomRightView.frame.origin.x = topRightView.frame.origin.x
            bottomRightView.frame.origin.y = bounds.maxY
            
            bottomLeftView.frame.origin.x = bounds.origin.x - lineWidth
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
        
        super.init(frame: .zero)
        
        topLeftView.backgroundColor = color
        topRightView.backgroundColor = color
        
        rightTopView.backgroundColor = color
        rightBottomView.backgroundColor = color
        
        bottomRightView.backgroundColor = color
        bottomLeftView.backgroundColor = color
        
        leftBottomView.backgroundColor = color
        leftTopView.backgroundColor = color
        
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
