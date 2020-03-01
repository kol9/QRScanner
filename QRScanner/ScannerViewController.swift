//
//  ViewController.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 15.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SafariServices


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    var metadataOutput: AVCaptureMetadataOutput!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView?
    var photoOutput: AVCapturePhotoOutput?
    var cameraSide = false
    var isSaveVideo = false
    var isMutedVideo = false
    var flashMode = false
    
    
    var movieOutput: AVCaptureMovieFileOutput!
    var outputURL: URL!
    var activeInput: AVCaptureDeviceInput!
    var cameraLongPressButtonRecognizer =  UILongPressGestureRecognizer()
    var cameraPanGestureRecognizer = UIPanGestureRecognizer()
    
    var videoPreviewPlayer: AVPlayer!
    var playerLayer: AVPlayerLayer!
    private var photoData: Data?
    
    @IBOutlet weak var buttonsView: ButtonsView!
    @IBOutlet weak var saveButton: ActionButton!
    @IBOutlet weak var volumeButton: ActionButton!
    @IBOutlet weak var closeButton: ActionButton!
    @IBOutlet weak var boltButton: ActionButton!
    @IBOutlet weak var switchButton: ActionButton!
    
    @IBOutlet weak var cameraButton: CameraButton!
    @IBOutlet weak var photoPreview: UIImageView!
    @IBOutlet weak var videoEditView: VideoEditView!
    
    
    func qrRecognizingOff() {
        qrCodeFrameView?.isHidden = true
    }
    
    @objc func changeFlashMode() {
        if !flashMode {
            flashMode = true
            
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
            boltButton.imgView.image = UIImage(systemName: "bolt.fill", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
            
        } else {
            flashMode = false
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
            boltButton.imgView.image = UIImage(systemName: "bolt.slash.fill", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        
    }
    
    @objc func changeVolumeMode() {
        if isMutedVideo {
            isMutedVideo = false
            videoEditView.setMuted(false)
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            volumeButton.imgView.image = UIImage(systemName: "speaker.2", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
            
        } else {
            isMutedVideo = true
            videoEditView.setMuted(true)
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            volumeButton.imgView.image = UIImage(systemName: "speaker.slash", withConfiguration: cfg)!.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
        
        print("Here")
    }
    
    func isHighDifference(_ a: CGRect, _ b: CGRect)->Bool {
        return abs(a.minX - b.minX + a.minY - b.minY + a.height - b.height) > 5
    }
    
    
    
    @objc func goToSaveView(isPhoto: Bool) {
        photoPreview.isHidden = !isPhoto
        playerLayer.isHidden = isPhoto
        
        volumeButton.isEnabled = !isPhoto
        volumeButton.isHidden = isPhoto
        saveButton.isEnabled = true
        saveButton.isHidden = false
        closeButton.isEnabled = true
        closeButton.isHidden = false
        
        
        boltButton.isEnabled = false
        boltButton.isHidden = true
        cameraButton.isEnabled = false
        cameraButton.isHidden = true
        switchButton.isEnabled = false
        switchButton.isHidden = true
        
        
        
        if !isPhoto {
            videoEditView.isHidden = false
            videoEditView.presentFrames()
        }
        
        captureSession.stopRunning()
    }
    
    
    @objc func switchCamera() {
        qrRecognizingOff()
        cameraSide = !cameraSide
        backToMainView()
    }
    
    @objc func backToMainView() {
        
        
        playerLayer.isHidden = true
        self.photoPreview.isHidden = true
        self.photoPreview.image = nil
        
        volumeButton.isEnabled = false
        volumeButton.isHidden = true
        saveButton.isEnabled = false
        saveButton.isHidden = true
        closeButton.isEnabled = false
        closeButton.isHidden = true
        
        
        boltButton.isEnabled = true
        boltButton.isHidden = false
        cameraButton.isEnabled = true
        cameraButton.isHidden = false
        switchButton.isEnabled = true
        switchButton.isHidden = false
        videoEditView.isHidden = true
        
        
        
        captureSession = AVCaptureSession()
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            if cameraSide == false {
                videoInput = try AVCaptureDeviceInput(device: getDevice(position: .back)!)
            } else {
                videoInput = try AVCaptureDeviceInput(device: getDevice(position: .front)!)
            }
            
        } catch {
            return
        }
        
        if ((captureSession?.canAddInput(videoInput))!) {
            captureSession?.addInput(videoInput)
            activeInput = videoInput
        } else {
            
            failed()
            return
        }
        
        metadataOutput = AVCaptureMetadataOutput()
        photoOutput = AVCapturePhotoOutput()
        
        
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            failed()
            return
        }
        
        
        
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        if ((captureSession?.canAddOutput(metadataOutput))!) {
            captureSession?.addOutput(metadataOutput)
            captureSession.addOutput(photoOutput!)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.zPosition = -20
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    
    
    @objc func saveMedia() {
        
        if (isSaveVideo) {
            saveVideo(videoEditView.videoURL!)
            isSaveVideo = false
        } else {
            
            
            DispatchQueue.global(qos: .background).async {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            let options = PHAssetResourceCreationOptions()
                            let creationRequest = PHAssetCreationRequest.forAsset()
                            creationRequest.addResource(with: .photo, data: self.photoData!, options: options)
                            
                        }, completionHandler: {_, error in
                            if let error = error {
                                print("Error occurred while saving photo to photo library: \(error)")
                            }
                        })
                    } else {
                        return
                    }
                })
            }
        }
        backToMainView()
    }
    
    
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard photoData != nil else {
            print("No photo data resource")
            return
        }
        
        goToSaveView(isPhoto: true)
        self.qrCodeFrameView?.frame = CGRect.zero
        previewLayer.isHidden = true
        photoPreview.image = UIImage(data: photoData!)
    }
    
    
    
    @objc func capturePhoto() {
        var photoSettings: AVCapturePhotoSettings!
        qrRecognizingOff()
        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if flashMode {
            photoSettings.flashMode = .on
        } else {
            photoSettings.flashMode = .off
        }
        
        
        photoSettings.isHighResolutionPhotoEnabled = false
        self.photoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        cameraLongPressButtonRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordVideoAction))
        cameraLongPressButtonRecognizer.minimumPressDuration = 0.2
        
        cameraButton.addGestureRecognizer(cameraLongPressButtonRecognizer)
        setupView()
    }
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func setupView() {
        
        photoPreview.contentMode = .scaleToFill
        photoPreview.frame = view.frame
        
        qrCodeFrameView = QRCodeFrameView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
        
        playerLayer = AVPlayerLayer()
        playerLayer.frame = UIScreen.main.bounds
        self.view.layer.addSublayer(playerLayer)
        playerLayer.zPosition = -15
        videoEditView.playerLayer = self.playerLayer
        
        
        cameraButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside);
        saveButton.addTarget(self, action: #selector(saveMedia), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(backToMainView), for: .touchUpInside)
        boltButton.addTarget(self, action: #selector(changeFlashMode), for: .touchUpInside)
        switchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        volumeButton.addTarget(self, action: #selector(changeVolumeMode), for: .touchUpInside)
        
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            
            UIView.animate(withDuration: 0.15, animations: {
                self.qrCodeFrameView?.alpha = 0
            }, completion: { _ in
                self.qrCodeFrameView?.isHidden = true
            })
            print("No QR code is detected")
            return
        }
        
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)
            if movieOutput.isRecording == false {
                qrCodeFrameView?.isHidden = false
            } else {
                qrCodeFrameView?.isHidden = true
            }
            let bnds = barCodeObject!.bounds
            
            if self.qrCodeFrameView?.frame == CGRect.zero {
                self.qrCodeFrameView?.frame = CGRect(x: bnds.minX - 5, y: bnds.minY - 2.5, width: bnds.width + 10, height: bnds.height + 10)
            }
            
            
            if(self.qrCodeFrameView != nil && isHighDifference(self.qrCodeFrameView!.frame, CGRect(x: bnds.minX - 5, y: bnds.minY - 2.5, width: bnds.width + 10, height: bnds.height + 10))) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.qrCodeFrameView?.frame = CGRect(x: bnds.minX - 5, y: bnds.minY - 2.5, width: bnds.width + 10, height: bnds.height + 10)
                })
                
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.qrCodeFrameView?.alpha = 1
            })
            
            if metadataObj.stringValue != nil {
                print(metadataObj.stringValue ?? "abacaba")
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backToMainView()
        
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    
    
}

extension ScannerViewController: AVCaptureFileOutputRecordingDelegate {
    
    class func setTorchMode(_ torchMode: AVCaptureDevice.TorchMode, for device: AVCaptureDevice) {
        if device.isTorchModeSupported(torchMode) && device.torchMode != torchMode {
            do
            {
                try device.lockForConfiguration()
                device.torchMode = torchMode
                device.unlockForConfiguration()
            }
            catch {
                print("Error:-\(error)")
            }
        }
    }
    
    @objc func moveZoom(_ move: UILongPressGestureRecognizer) {
        
        var newPos = move.location(in: self.view)
        
        let device = activeInput.device
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = factor
                device.unlockForConfiguration()
            } catch {
                print("Error:-\(error)")
            }
        }
        
        let camPos = cameraButton.superview!.center
        
        let scale = sqrt(pow((newPos.x - camPos.x), 2) + pow((newPos.y - camPos.y),2))
        
        
        if (scale >= 0 && scale <= 400) {
            
            
            let scaleFactor = (scale) / 325 * 4
            
            let newScaleFactor = minMaxZoom(scaleFactor)
            
            switch move.state {
            case .began:
                fallthrough
            case .changed:
                update(scale: newScaleFactor)
                lastZoomFactor = minMaxZoom(newScaleFactor)
                
            case .ended:
                lastZoomFactor = minMaxZoom(minimumZoom)
                update(scale: minimumZoom)
            default:
                break
            }
        } else if scale < 0{
            lastZoomFactor = minMaxZoom(minimumZoom)
            update(scale: minimumZoom)
        }
    }
    
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        
        print("capture output: started recording to \(String(describing: outputURL))")
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            if error == nil {
                videoEditView.addUrl(outputFileURL)
                isSaveVideo = true
                goToSaveView(isPhoto: false)
            }
        }
        outputURL = nil
        print("Just captured a video")
    }
    
    
    @objc func saveVideo(_ withURL: URL) {
        
        let url = cropVideo(sourceURL: withURL, startTime: videoEditView.startTime, endTime: videoEditView.endTime)
        
        DispatchQueue.global(qos: .background).async {
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
        }
    }
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) -> URL
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        
        let sourceVideoTrack: AVAssetTrack? = asset.tracks(withMediaType: .video)[0]
        let composition = AVMutableComposition()
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = sourceVideoTrack!.preferredTransform
        
        let x: CMTimeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        
        _ = try? compositionVideoTrack?.insertTimeRange(x, of: sourceVideoTrack!, at: .zero)
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mov")
        } catch let error {
            print(error)
        }
        
        
        var exportSession: AVAssetExportSession!
        
        if (isMutedVideo) {
            exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        } else {
            exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        }
        
        try? fileManager.removeItem(at: outputURL)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
        
        return outputURL
    }
    
    
    
    
    
    
    
    @objc func stopRecording() {
        
        if movieOutput.isRecording == true {
            print("Stop")
            movieOutput.stopRecording()
        }
    }
    
    
    
    
    @objc func recordVideoAction(_ sender: UIButton) {
        
        if cameraLongPressButtonRecognizer.state == .began {
            
            
            cameraLongPressButtonRecognizer.addTarget(self, action: #selector(moveZoom))
            let device = activeInput.device
            
            if device.isTorchAvailable == true &&  flashMode == true {
                ScannerViewController.setTorchMode(.on, for: device)
            }
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: fileUrl)
            
            print("start")
            boltButton.isHidden = true
            boltButton.isEnabled = false
            switchButton.isHidden = true
            boltButton.isEnabled = false
            
            UIView.animate(withDuration: 0.2, animations: {
                self.cameraButton.transform = CGAffineTransform(scaleX: 1.3125, y: 1.3125)
            })
            
            cameraPanGestureRecognizer.isEnabled = true
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
        } else if cameraLongPressButtonRecognizer.state == .ended{
            cameraButton.removeGestureRecognizer(cameraPanGestureRecognizer)
            print("Stop")
            cameraPanGestureRecognizer.isEnabled = false
            let device = activeInput.device
            
            if device.isTorchAvailable == true {
                ScannerViewController.setTorchMode(.off, for: device)
            }
            
            boltButton.isHidden = false
            boltButton.isEnabled = true
            switchButton.isHidden = false
            boltButton.isEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.cameraButton.transform = .identity
            })
            
            movieOutput.stopRecording()
        }
    }
}

