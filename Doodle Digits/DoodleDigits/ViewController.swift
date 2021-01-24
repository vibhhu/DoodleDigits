//
//  ViewController.swift
//  MNISTHandwritingRecognition
//
//  Created by Vibhhu Sharma on 22/01/21.
//  Copyright © 2021 Vibhhu Sharma. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    //@IBOutlet weak var digitLabel: UILabel!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var digitLabel: UILabel!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupVision()
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {fatalError("Can not load Vision ML Model")}
        
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results
            else {
                print("No results")
                return }
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8 })
            .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.digitLabel.text = classifications.first
        }
        
    }
    @IBAction func clearCanvas(_ sender: Any) {
            canvasView.clearCanvas()
    }
    @IBAction func recognizeDigit(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width:28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        do {
            try
                imageRequestHandler.perform(self.requests)
        }catch {
                print(error)
            }
        }
        
    }
    
    func scaleImage(image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height:size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    


