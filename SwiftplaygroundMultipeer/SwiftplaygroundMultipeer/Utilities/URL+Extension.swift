//
//  URL+Extension.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 12/05/2024.
//

import Foundation
import UIKit

extension URL {
    func loadImage() -> UIImage? {
        do {
            let imageData = try Data(contentsOf: self)
            return UIImage(data: imageData)
        } catch {
            LogManager.shared.error(self, "Error loading image : \(error)")
            return nil
        }
        
    }
}
