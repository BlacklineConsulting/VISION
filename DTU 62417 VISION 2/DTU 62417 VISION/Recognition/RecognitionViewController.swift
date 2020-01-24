//
//  RecognitionViewController.swift
//  DTU 62417 VISION
//
//  Created by Arif Yildirim on 01/12/2019.
//  Copyright © 2019 Arif Yildirim. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

class RecognitionViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var imagePicker = UIImagePickerController()
    
    private var model = Resnet50()
    
    @IBOutlet weak var recognitionImageView: UIImageView!
    
    @IBOutlet weak var recognitionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        self.recognitionImageView.image = pickedImage
        
        recognizeImage(image: pickedImage)
    }
    
    private func recognizeImage(image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("ciImage could not be created")
            
        }
        
        guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
            fatalError("Resnet50 could not be created")
        }
        
        let visionRequest = VNCoreMLRequest(model: visionModel) {
            request, error in if error != nil {
                return
            }
            
            guard let analysis = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let visualAnalysis = analysis.map {
                observation in "\(observation.identifier) \(observation.confidence * 100)"
            }
            
            DispatchQueue.main.async {
                self.recognitionTextView.text = visualAnalysis.joined(separator: "\n")
            }
        }
        
        let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
    }
    
    
    @IBAction func recognitionCameraButton(_ sender: UIBarButtonItem) {
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    
    
}
