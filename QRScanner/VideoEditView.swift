//
//  VideoEditView.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 23.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import AVFoundation
import UIKit

class VideoEditView: UIView {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    let images: [UIImage] = []
    
    
    var playerLayer: AVPlayerLayer!
    var player: AVPlayer!
    var videoURL: URL? = nil
    
    var startTime: Double = 0
    var endTime: Double = 0
    
    
    func setMuted(_ v: Bool) {
        player.isMuted = v
    }
    
    func resetViews() {
        leftArrow.frame = leftDefaultRect
        rightArrow.frame = rightDefaultRect
        
        let path = UIBezierPath(roundedRect: CGRect(x: 9, y: 15, width: self.bounds.width - 20, height: bounds.height - 30), cornerRadius: 7)
        shape.path = path.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        shape.lineWidth = 5
        
        
        
        let pathL = UIBezierPath(roundedRect: CGRect(x: 0, y: 16, width: leftArrow.frame.minX, height: bounds.height - 32), cornerRadius: 5)
        shapeL.path = pathL.cgPath
        shapeL.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
        shapeL.lineWidth = 1
        shapeL.zPosition = -9
        
        
        let pathR = UIBezierPath(roundedRect: CGRect(x: rightArrow.frame.maxX, y: 16, width: (imagesView.frame.maxX - rightArrow.frame.maxX), height: bounds.height - 32), cornerRadius: 5)
        shapeR.path = pathR.cgPath
        shapeR.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
        shapeR.lineWidth = 1
        shapeR.zPosition = -9
        
        
        
    }
    
    func addUrl(_ url: URL) {
        
        
        resetViews()
        
        videoURL = url
        
        let asset = AVURLAsset(url: url)
        
        var percent = Double((leftArrow.frame.minX)) / Double(imagesView.frame.maxX)
        var allTime = asset.duration.seconds
        var time = percent * allTime
        startTime = time
        
        
        percent = Double((rightArrow.frame.maxX)) / Double(imagesView.frame.maxX)
        allTime = asset.duration.seconds
        time = percent * allTime
        endTime = time
        
        
        player = AVPlayer(url: url)
        playerLayer.player = player
        playerLayer.isHidden = false
        player.play()
        
        
        
        leftLabel.text = getFormat(time: Int(startTime))
        rightLabel.text = String("-\(getFormat(time: Int(allTime - endTime)))")
    }
    
    
    var leftDefaultRect: CGRect!
    var rightDefaultRect: CGRect!
    
    
    var shape = CAShapeLayer()
    var shapeL = CAShapeLayer()
    var shapeR = CAShapeLayer()
    
    
    
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = .encodedPixels
        
        assetIG.maximumSize = CGSize(width: 100, height: 200)
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }
        
        return UIImage(cgImage: thumbnailImageRef)
    }
    
    
    
    
    func presentFrames() {
        
        let asset = AVAsset(url: videoURL!)
        
        let dur: Double = asset.duration.seconds
        for i in 0..<7 {
            
            var t: TimeInterval = dur / 6
            t *= Double(i)
            DispatchQueue.global(qos: .background).async {
                let image = self.imageFromVideo(url: self.videoURL!, at: t)
                
                DispatchQueue.main.async {
                    self.imagesViews[i].image = image
                }
            }
        }
    }
    
    
    
    
    func getFormat(time: Int) -> String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    var leftLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    var rightLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    func setupView() {
        
        backgroundColor = .clear
        addSubview(imagesView)
        
        
        for i in 0..<7 {
            imagesView.addSubview(imagesViews[i])
        }
        
        addSubview(leftArrow)
        addSubview(rightArrow)
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movingLeftArrow))
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movingRightArrow))
        
        leftPanGestureRecognizer.isEnabled = true
        rightPanGestureRecognizer.isEnabled = true
        
        leftArrow.addGestureRecognizer(leftPanGestureRecognizer)
        rightArrow.addGestureRecognizer(rightPanGestureRecognizer)
        
        
        leftDefaultRect = CGRect(x: 10, y: 14, width: 12, height: bounds.height - 27)
        rightDefaultRect = CGRect(x: bounds.width - 24, y: 14, width: 12, height: bounds.height - 27)
    }
    
    
    
    @objc func movingLeftArrow(_ recognizer:UIPanGestureRecognizer) {
        
        let newPos = recognizer.location(in: self)
        var X = newPos.x
        
        if X < frame.minX - 12 {
            X = frame.minX - 12
        }
        if X > self.frame.width {
            X = self.frame.width
        }
        if (X > rightArrow.frame.minX - 12) {
            X = rightArrow.frame.minX - 12
        }
        
        
        
        
        let asset = AVAsset(url: videoURL!)
        let percent = Double((X - 2)) / Double(imagesView.frame.maxX)
        
        let allTime = asset.duration.seconds
        let time = percent * allTime
        
        
        
        player.pause()
        
        let tim = CMTime(seconds: time, preferredTimescale: 1000)
        
        startTime = time
        
        
        leftLabel.text = getFormat(time: Int(startTime))
        
        
        self.player.seek(to: tim, toleranceBefore: .zero, toleranceAfter: .zero)
        
        
        switch recognizer.state {
        case .began:
            fallthrough
        case .changed:
            let newRect = CGRect(x: X, y: 14, width: 12, height: bounds.height - 27)
            leftArrow.frame = newRect
            
            let path = UIBezierPath(roundedRect: CGRect(x: X - 1, y: 15, width: rightArrow.frame.maxX - X + 2, height: bounds.height - 30), cornerRadius: 7)
            shape.path = path.cgPath
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeColor = UIColor.black.cgColor
            shape.lineWidth = 5
            
            
            let pathL = UIBezierPath(roundedRect: CGRect(x: 0, y: 16, width: leftArrow.frame.minX, height: bounds.height - 32), cornerRadius: 5)
            shapeL.path = pathL.cgPath
            shapeL.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
            shapeL.lineWidth = 1
            shapeL.zPosition = -9
        default:
            break
        }
    }
    
    @objc func movingRightArrow(_ recognizer:UIPanGestureRecognizer) {
        let newPos = recognizer.location(in: self)
        var X = newPos.x
        
        if X < 0 {
            X = 0
        }
        if X > self.frame.width - 14 {
            X = self.frame.width - 14
        }
        
        if (X < leftArrow.frame.maxX) {
            X = leftArrow.frame.maxX
        }
        
        let asset = AVAsset(url: videoURL!)
        let percent = Double((X + 14)) / Double(imagesView.frame.maxX)
        
        let allTime = asset.duration.seconds
        
        rightLabel.text = String("-\(getFormat(time: Int(allTime - endTime)))")
        
        let time = percent * allTime
        let tim = CMTime(seconds: time, preferredTimescale: 1000)
        
        endTime = time
        
        
        self.player.seek(to: tim, toleranceBefore: .zero, toleranceAfter: .zero)
        
        
        switch recognizer.state {
        case .began:
            fallthrough
        case .changed:
            let newRect = CGRect(x: X, y: 14, width: 12, height: bounds.height - 27)
            rightArrow.frame = newRect
            let path = UIBezierPath(roundedRect: CGRect(x: leftArrow.frame.minX - 1, y: 15, width: X - leftArrow.frame.minX + 14, height: bounds.height - 30), cornerRadius: 7)
            shape.path = path.cgPath
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeColor = UIColor.black.cgColor
            shape.lineWidth = 5
            
            
            let pathR = UIBezierPath(roundedRect: CGRect(x: rightArrow.frame.maxX, y: 16, width: (imagesView.frame.maxX - rightArrow.frame.maxX), height: bounds.height - 32), cornerRadius: 5)
            shapeR.path = pathR.cgPath
            shapeR.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
            shapeR.lineWidth = 1
            shapeR.zPosition = -9
            
        default:
            break
        }
    }
    
    
    
    
    let imagesViews: [UIImageView] = {
        var imgViews: [UIImageView] = []
        
        for i in 0..<7 {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            imgViews.append(view)
        }
        
        return imgViews
    }()
    
    let imagesView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    
    let leftArrow: UIImageView = {
        
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 2
        imgView.contentMode = .center
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let img = UIImage(systemName: "chevron.compact.left", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        imgView.image = img
        imgView.backgroundColor = .black
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    
    let rightArrow: UIImageView = {
        
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 2
        imgView.contentMode = .center
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let img = UIImage(systemName: "chevron.compact.right", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        imgView.image = img
        imgView.backgroundColor = .black
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    
    
    
    
    override func layoutSubviews() {
        imagesView.frame = CGRect(x: 0, y: 16, width: bounds.width, height: bounds.height - 32)
        
        for i in 0..<7 {
            imagesViews[i].frame = CGRect(x: CGFloat(i * Int(imagesView.frame.width) / 7), y:0, width: (imagesView.frame.width) / 7 + 1, height: imagesView.frame.height)
        }
        
        let path2 = UIBezierPath(roundedRect: CGRect(x: 0, y: 16, width: bounds.width, height: bounds.height - 32), cornerRadius: 5)
        let shape2 = CAShapeLayer()
        shape2.path = path2.cgPath
        
        shape2.strokeColor = UIColor.white.cgColor
        shape2.fillColor = UIColor.clear.cgColor
        shape2.lineWidth = 2
        shape2.zPosition = -10
        
        
        
        imagesView.layer.zPosition = -11
        shape.zPosition = -8
        layer.addSublayer(shape2)
        layer.addSublayer(shape)
        layer.addSublayer(shapeL)
        layer.addSublayer(shapeR)
        
        
        leftLabel.frame = CGRect(x: bounds.minX + 6, y: 76, width: 34, height: 14)
        rightLabel.frame = CGRect(x: bounds.maxX - 43, y: 76, width: 50, height: 14)
        
    }
    
    
}

