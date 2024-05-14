//
//  MultipeerConnectionDataTransformer.swift
//
//  Created by Bruno PUJOL on 05/09/2023.
//

import Foundation

protocol MultipeerConnectionDataTransformer {
    func toData(_ input: Any) -> Data?
}

class MultipeerConnectionDataTransformerImpl : MultipeerConnectionDataTransformer {
    func toData(_ input: Any) -> Data? {
        if let message = input as? String {
            return message.data(using: .utf8)
        } else if let data = input as? Data {
            return data
        } else {
            LogManager.shared.error(self, "Fail to transform input to data")
            return nil
        }
    }
}
