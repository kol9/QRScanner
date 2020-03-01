//
//  ActionButton.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 17.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    func setupView() {
       
        backgroundColor = .clear
        
        
        addSubview(backView)
        var img: UIImage = UIImage()
        if self.tag == 1 {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
            img = UIImage(systemName: "bolt.slash.fill", withConfiguration: cfg)!
        } else if self.tag == 2 {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            img = UIImage(systemName: "arrow.2.circlepath", withConfiguration: cfg)!
        } else if self.tag == 3 {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            img = UIImage(systemName: "xmark", withConfiguration: cfg)!
        }else if self.tag == 4 {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            img = UIImage(systemName: "speaker.2", withConfiguration: cfg)!
        }else if self.tag == 5 {
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            img = UIImage(systemName: "arrow.down.to.line.alt", withConfiguration: cfg)!
        }
        
        addSubview(imgView)
        imgView.image = img.withTintColor(.white, renderingMode: .alwaysOriginal)
        
    }
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 19
        view.alpha = 0
        return view
    }()
    
    let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.2, animations: {
                    self.backView.alpha = 0.7
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.backView.alpha = 0
                })
            }
        }
    }
    
    override func layoutSubviews() {
        titleLabel?.text = ""
        imgView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        
        backView.frame = CGRect(x: 5, y: 5, width: bounds.width - 10, height: bounds.height - 10)
    }
    
    
}
