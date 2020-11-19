//
//  WatsonRecognitionService.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit

final class WatsonRecognitionService: ServiceProtocol {
    
    func recognizeWire(on image: UIImage) -> RecognitionModel {
        let resultUSB = RecognitionVariants(variant: "usb", confidence: "90")
        let resultHDMI = RecognitionVariants(variant: "hdmi", confidence: "9")
        let model = RecognitionModel(results: [resultUSB, resultHDMI], error: nil)
        return model
    }
}
