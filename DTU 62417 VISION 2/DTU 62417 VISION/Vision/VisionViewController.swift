//
//  VisionViewController.swift
//  DTU 62417 VISION
//
//  Created by Arif Yildirim on 02/12/2019.
//  Copyright © 2019 Arif Yildirim. All rights reserved.
//

/*
THIS AI VISION APP WILL NOT RUN ON THE SIMULATOR, A PHYSICAL DEVICE IS REQUIRED.
 */

import Foundation
import AVFoundation
import UIKit
import CoreML
import Vision

class VisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var visionImageView: UIImageView!
    
    @IBOutlet weak var visionTextView: UITextView!
    
    private let visionModel = YOLOv3()
    
    private var requests = [VNCoreMLRequest]()
    
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLiveCamera()
        liveCameraRequest()
    }
    
    private func liveCameraRequest() {
        
        guard let model = try? VNCoreMLModel(for: self.visionModel.model) else {
            fatalError("YOLOv3 could not be created")
        }
        
        let request = VNCoreMLRequest(model: model) {
            request, error in if error != nil {
                return
            }
            
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            let visionAnalysis = observations.map {
                observation in "\(observation.self) \(observation.confidence * 100)"
            }
            
            DispatchQueue.main.async {
                self.visionTextView.text = visionAnalysis.joined(separator: "\n")
            }
            
            print(observations)
        }
        
        self.requests.append(request)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let camera = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: camera]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
            
        } catch {
            print(error)
        }
    }
    
    private func startLiveCamera() {
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        let videoDevice = AVCaptureDevice.default(for: .video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        
        let deviceOutput = AVCaptureVideoDataOutput()
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = visionImageView.bounds
        visionImageView.layer.addSublayer(imageLayer)
        
        session.commitConfiguration()
        session.startRunning()
    }
    
}

