//
//  CameraViewController.swift
//  QRScanner
//
//  Created by Nikolay Yarlychenko on 21.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


//class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        <#code#>
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//
//
//
//    class PhotoCaptureProcessor: NSObject {
//        private(set) var requestedPhotoSettings: AVCapturePhotoSettings
//
//        private let willCapturePhotoAnimation: () -> Void
//
//        private let livePhotoCaptureHandler: (Bool) -> Void
//
//        lazy var context = CIContext()
//
//        private let completionHandler: (PhotoCaptureProcessor) -> Void
//
//        private let photoProcessingHandler: (Bool) -> Void
//
//        private var photoData: Data?
//
//        private var livePhotoCompanionMovieURL: URL?
//
//        private var portraitEffectsMatteData: Data?
//
//        private var semanticSegmentationMatteDataArray = [Data]()
//
//        private var maxPhotoProcessingTime: CMTime?
//
//        init(with requestedPhotoSettings: AVCapturePhotoSettings,
//             willCapturePhotoAnimation: @escaping () -> Void,
//             livePhotoCaptureHandler: @escaping (Bool) -> Void,
//             completionHandler: @escaping (PhotoCaptureProcessor) -> Void,
//             photoProcessingHandler: @escaping (Bool) -> Void) {
//            self.requestedPhotoSettings = requestedPhotoSettings
//            self.willCapturePhotoAnimation = willCapturePhotoAnimation
//            self.livePhotoCaptureHandler = livePhotoCaptureHandler
//            self.completionHandler = completionHandler
//            self.photoProcessingHandler = photoProcessingHandler
//        }
//
//        private func didFinish() {
//            if let livePhotoCompanionMoviePath = livePhotoCompanionMovieURL?.path {
//                if FileManager.default.fileExists(atPath: livePhotoCompanionMoviePath) {
//                    do {
//                        try FileManager.default.removeItem(atPath: livePhotoCompanionMoviePath)
//                    } catch {
//                        print("Could not remove file at url: \(livePhotoCompanionMoviePath)")
//                    }
//                }
//            }
//
//            completionHandler(self)
//        }
//
//    }
    
    
    
//    //MARK:- Capturing Photo
//      private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
//
//    private let sessionQueue = DispatchQueue(label: "session queue")
//
//    private let photoOutput = AVCapturePhotoOutput()
//
//    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
//
//    @IBOutlet private weak var photoButton: UIButton!
//
//    private func capturePhoto(_ photoButton: UIButton) {
//
//        sessionQueue.async {
//             var photoSettings = AVCapturePhotoSettings()
//            photoSettings.isHighResolutionPhotoEnabled = true
//            photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
//
//
//            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
//                // Flash the screen to signal that AVCam took a photo.
//                DispatchQueue.main.async {
//                    self.previewView.videoPreviewLayer.opacity = 0
//                    UIView.animate(withDuration: 0.25) {
//                        self.previewView.videoPreviewLayer.opacity = 1
//                    }
//                }
//            }, livePhotoCaptureHandler: { capturing in
//                self.sessionQueue.async {
//                    if capturing {
//                        self.inProgressLivePhotoCapturesCount += 1
//                    } else {
//                        self.inProgressLivePhotoCapturesCount -= 1
//                    }
//
//                    let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
//                    DispatchQueue.main.async {
//                        if inProgressLivePhotoCapturesCount > 0 {
//                            self.capturingLivePhotoLabel.isHidden = false
//                        } else if inProgressLivePhotoCapturesCount == 0 {
//                            self.capturingLivePhotoLabel.isHidden = true
//                        } else {
//                            print("Error: In progress Live Photo capture count is less than 0.")
//                        }
//                    }
//                }
//            }, completionHandler: { photoCaptureProcessor in
//                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
//                self.sessionQueue.async {
//                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
//                }
//            }, photoProcessingHandler: { animate in
//                // Animates a spinner while photo is processing
//                DispatchQueue.main.async {
//                    if animate {
//                        self.spinner.hidesWhenStopped = true
//                        self.spinner.center = CGPoint(x: self.previewView.frame.size.width / 2.0, y: self.previewView.frame.size.height / 2.0)
//                        self.spinner.startAnimating()
//                    } else {
//                        self.spinner.stopAnimating()
//                    }
//                }
//            }
//            )
//            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
//        }
//
//    }
//
//
//}
