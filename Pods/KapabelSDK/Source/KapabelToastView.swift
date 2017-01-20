//
//  KapabelToastView.swift
//  Kapabel SDK
//
//  Created by Oyvind Kvanes on 06/08/16.
//  Copyright © 2016 Kvanes AS. All rights reserved.
//


import UIKit

let KapabelToastViewPortraitOffsetYAttributeName = "KapabelToastViewPortraitOffsetYAttributeName"
let KapabelToastViewLandscapeOffsetYAttributeName = "KapabelToastViewLandscapeOffsetYAttributeName"
let KapabelToastViewFontAttributeName = "KapabelToastViewFontAttributeName"


// MARK: Toast View
class KapabelToastView: UIView {
    
    var backgroundView: UIView!
    var textLabel: UILabel!
    var textInsets: UIEdgeInsets!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        
        self.isUserInteractionEnabled = false
        
        self.backgroundView = UIView()
        self.backgroundView.frame = self.bounds
        self.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.backgroundView.layer.cornerRadius = 5.0
        self.backgroundView.clipsToBounds = true
        self.addSubview(self.backgroundView)
        
        self.textLabel = UILabel()
        self.textLabel.frame = self.bounds
        self.textLabel.textColor = UIColor.white
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.font = type(of: self).defaultValueForAttributeName(
            KapabelToastViewFontAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! UIFont
        self.textLabel.numberOfLines = 0
        self.textLabel.textAlignment = .center;
        self.addSubview(self.textLabel)
        self.textInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    func updateView() {
        let deviceWidth = UIScreen.main.bounds.width
        let constraintSize = CGSize(width: deviceWidth * (280.0 / 320.0), height: CGFloat.greatestFiniteMagnitude)
        let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
        self.textLabel.frame = CGRect(
            x: self.textInsets.left,
            y: self.textInsets.top,
            width: textLabelSize.width,
            height: textLabelSize.height
        )
        self.backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right,
            height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
        )
        
        var x: CGFloat
        var y: CGFloat
        var width:CGFloat
        var height:CGFloat
        
        let screenSize = UIScreen.main.bounds.size
        let backgroundViewSize = self.backgroundView.frame.size
        
        let orientation = UIApplication.shared.statusBarOrientation
        let systemVersion = (UIDevice.current.systemVersion as NSString).floatValue
        
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        
        let portraitOffsetY = CGFloat(type(of: self).defaultValueForAttributeName(
            KapabelToastViewPortraitOffsetYAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! NSNumber)
        let landscapeOffsetY = CGFloat(type(of: self).defaultValueForAttributeName(
            KapabelToastViewLandscapeOffsetYAttributeName,
            forUserInterfaceIdiom: userInterfaceIdiom
            ) as! NSNumber)
        
        if UIInterfaceOrientationIsLandscape(orientation) && systemVersion < 8.0 {
            width = screenSize.height
            height = screenSize.width
            y = landscapeOffsetY
        } else {
            width = screenSize.width
            height = screenSize.height
            if UIInterfaceOrientationIsLandscape(orientation) {
                y = landscapeOffsetY
            } else {
                y = portraitOffsetY
            }
        }
        
        x = (width - backgroundViewSize.width) * 0.5
        y = height - (backgroundViewSize.height + y)
        self.frame = CGRect(x: x, y: y, width: backgroundViewSize.width, height: backgroundViewSize.height);
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
        let pointInWindow = self.convert(point, to: self.superview)
        let contains = self.frame.contains(pointInWindow)
        if contains && self.isUserInteractionEnabled {
            return self
        }
        return nil
    }
    
}

// MARK: Toast View extension
extension KapabelToastView {
    fileprivate struct Singleton {
        static var defaultValues: [String: [UIUserInterfaceIdiom: AnyObject]] = [
            KapabelToastViewFontAttributeName: [
                .unspecified: UIFont.systemFont(ofSize: 12),
                .phone: UIFont.systemFont(ofSize: 12),
                .pad: UIFont.systemFont(ofSize: 16),
            ],
            KapabelToastViewPortraitOffsetYAttributeName: [
                .unspecified: 30 as AnyObject,
                .phone: 30 as AnyObject,
                .pad: 60 as AnyObject,
            ],
            KapabelToastViewLandscapeOffsetYAttributeName: [
                .unspecified: 20 as AnyObject,
                .phone: 20 as AnyObject,
                .pad: 40 as AnyObject,
            ],
            ]
    }
    
    class func defaultValueForAttributeName(_ attributeName: String,
                                            forUserInterfaceIdiom userInterfaceIdiom: UIUserInterfaceIdiom)
        -> AnyObject {
            let valueForAttributeName = Singleton.defaultValues[attributeName]!
            if let value: AnyObject = valueForAttributeName[userInterfaceIdiom] {
                return value
            }
            return valueForAttributeName[.unspecified]!
    }
    
    
}
