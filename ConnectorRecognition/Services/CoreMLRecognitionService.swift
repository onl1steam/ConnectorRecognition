//
//  CoreMLRecognitionService.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit
import CoreML
import Vision
import ImageIO

final class CoreMLRecognitionService: ServiceProtocol {
    
    private var recognitionResponse: RecognitionModel = RecognitionModel(results: nil, error: nil)
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MyImageClassifier().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func recognizeWire(on image: UIImage) -> RecognitionModel {
        updateClassifications(for: image)
        return recognitionResponse
    }
    
    /// - Tag: PerformRequests
    private func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            try handler.perform([self.classificationRequest])
        } catch {
            print("Failed to perform classification.\n\(error.localizedDescription)")
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    private func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            recognitionResponse = RecognitionModel(results: nil,
                                                      error: "Невозможно классифицировать изображение.\n\(error!.localizedDescription)")
            return
        }
        let classifications = results as! [VNClassificationObservation]
        
        if classifications.isEmpty {
            recognitionResponse = RecognitionModel(results: nil, error: "Изображение не распознано.")
        } else {
            let topClassifications = classifications.prefix(2)
            var recognitionVariants: [RecognitionVariants] = []
            
            Array(topClassifications).forEach { (classification) in
                let confidence = String(Int(classification.confidence * 100))
                let recognitionVariant = RecognitionVariants(variant: classification.identifier,
                                                             confidence: confidence)
                recognitionVariants.append(recognitionVariant)
            }
            recognitionResponse = RecognitionModel(results: recognitionVariants, error: nil)
        }
    }
}
