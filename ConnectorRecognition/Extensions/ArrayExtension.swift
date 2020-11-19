//
//  ArrayExtension.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import Foundation

extension Array {
    
    /// Subscript для безопасного доступа к элементам массива.
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
