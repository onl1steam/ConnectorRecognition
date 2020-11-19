//
//  State.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import Foundation

enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}
