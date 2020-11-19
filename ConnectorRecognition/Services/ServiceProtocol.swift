//
//  ServiceProtocol.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit

protocol ServiceProtocol {
    func recognizeWire(on image: UIImage) -> RecognitionModel
}
