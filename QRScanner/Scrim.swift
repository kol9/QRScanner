//
//  Scrim.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 22.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
class Scrim: UIView {
    
    let gradientColors: [CGColor] = [
        UIColor(red: 0.0 / 255.0, green:  0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.02).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.05).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.12).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.2).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.29).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.39).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.5).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.61).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.71).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.8).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.88).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.95).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.98).cgColor,
        UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1).cgColor,
    ]
    
    private var gradient: CAGradientLayer!
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        if self.tag == 0 {
            self.transform = CGAffineTransform(rotationAngle: .pi)
            backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.6)
        } else {
            backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.5)
        }
        
    
        gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = gradientColors
        gradient.locations = [0,0.09,0.19,0.28,0.38,0.48,0.57,0.66,0.74,0.81,0.88,0.93,0.97,0.99,1]
        layer.mask = gradient
    }
    
}
