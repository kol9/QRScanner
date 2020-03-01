//
//  CameraButton.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 22.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class CameraButton: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    func setupView() {
        progressShape = CAShapeLayer()
        backgroundColor = .clear
        self.layer.cornerRadius = 48
    }
    
    func setHide(_ isHidden:Bool) {
        self.isHidden = isHidden
    }
    
    let externalCircle: CAShapeLayer = {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 48, y: 48), radius: CGFloat(29), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = 6
        shapeLayer.strokeColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
    let internalCircle: CAShapeLayer = {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 48, y: 48), radius: CGFloat(24), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5).cgColor
        
        return shapeLayer
    }()
    
    var progressShape: CAShapeLayer!
    
    func progressAnimationStop() {
        
        progressShape.removeAllAnimations()
        progressShape.strokeStart = 0
        progressShape.strokeEnd = 0
    }
    
    func progressAnimationStart() {
        
        let animation1 = CABasicAnimation(keyPath: "strokeEnd")
        animation1.fromValue = 0
        animation1.toValue = 0.5
        animation1.timingFunction = CAMediaTimingFunction(name: .linear)
        animation1.duration = 7
        animation1.fillMode = .forwards
        animation1.isRemovedOnCompletion = false
    
        progressShape.add(animation1, forKey: "strokeEnd")
        animation1.isRemovedOnCompletion = true
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.keyTimes = [0, 1]
        animation.values = [-Double.pi / 2, 1.5 * Double.pi]
        animation.duration = 14
        animation.repeatCount = .infinity
        animation.beginTime = CACurrentMediaTime() + 7
        animation.isRemovedOnCompletion = true
        animation.fillMode = .removed

        progressShape.add(animation, forKey: "transform.rotation")
    }
    
    
    override func layoutSubviews() {
        layer.addSublayer(externalCircle)
        layer.addSublayer(internalCircle)
        
        externalCircle.frame = bounds
    
        progressShape.path = UIBezierPath(arcCenter: CGPoint(x: 48, y: 48), radius: CGFloat(29), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
        
        layer.addSublayer(progressShape)
        progressShape.strokeColor = UIColor.red.cgColor
        progressShape.fillColor = UIColor.clear.cgColor
        progressShape.lineWidth = externalCircle.lineWidth
        progressShape.strokeStart = 0
        progressShape.strokeEnd = 0
        progressShape.frame = externalCircle.frame
        progressShape.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)

    }
    
}
