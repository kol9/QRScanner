//
//  QRCodeFrameView.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 17.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit


class QRCodeFrameView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var img: UIImage?
    var imgView = UIImageView()
    func setupView() {
        backgroundColor = .clear
       
        layer.cornerRadius = 20
        backgroundColor = .clear
        addSubview(imgView)
        
        
        let cfg = UIImage.SymbolConfiguration(pointSize: 100, weight: .ultraLight, scale: .large)
        img = UIImage(systemName: "viewfinder", withConfiguration: cfg)!.withTintColor(.green, renderingMode: .alwaysOriginal)
        imgView.image = img
        imgView.contentMode = .scaleAspectFill
        isHidden = true
    }
    

    override func layoutSubviews() {
        
        imgView.frame = CGRect(x: -10, y: -10, width: bounds.width + 20, height: bounds.height + 20)

    
    }

    
}
