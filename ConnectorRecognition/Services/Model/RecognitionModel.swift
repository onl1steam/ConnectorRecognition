//
//  RecognitionModel.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import Foundation

struct RecognitionVariants {
    var variant: String
    var confidence: String
}

struct RecognitionModel {
    var results: [RecognitionVariants]?
    var error: String?
}
