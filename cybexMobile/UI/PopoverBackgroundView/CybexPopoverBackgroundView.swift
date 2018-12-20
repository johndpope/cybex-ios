//
//  CybexPopoverBackgroundView.swift
//  cybexMobile
//
//  Created by DKM on 2018/12/13.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

class CybexPopoverBackgroundView: UIPopoverBackgroundView {
    
    var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        imageView = UIImageView(image: ThemeManager.currentThemeIndex == 0 ? R.image.arrowUpBlack() : R.image.arrowUpWhite())
        imageView.frame = CGRect(x: frame.width * 0.5 - 12, y: 0, width: 24, height: 10)
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var arrowOffset: CGFloat {
        get {
            return 0
        }
        set {
            
        }
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return UIPopoverArrowDirection.up
        }
        set{
            switch newValue {
            case .down:
                imageView.frame = CGRect(x: frame.width * 0.5 - 12, y: self.frame.height - 10, width: 24, height: 10)
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                break
            case .up:
                imageView.frame = CGRect(x: frame.width * 0.5 - 12, y: 0, width: 24, height: 10)
                break
            default:
                break
            }
        }
    }
    
    public override static func arrowBase() -> CGFloat {
        return 0
    }
    
    public override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    public override static func arrowHeight() -> CGFloat {
        return 0
    }
}