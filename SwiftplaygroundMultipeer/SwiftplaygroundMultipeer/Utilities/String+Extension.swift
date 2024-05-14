//
//  String+Extension.swift
//  PujolGolfHelper
//
//  Created by Bruno PUJOL on 06/09/2023.
//

import Foundation

extension String {
    func getPart(_ separator: Character, isFirst: Bool = true) -> String {
        if !contains(separator) {
            return self
        }
        if #available(iOS 16.0, *) {
            let split = split(separator: separator)
            return String(isFirst ? split.first! : split.last!)
        } else {
            var before = String()
            var after = String()
            var found = false
            
            for char in self {
                if found {
                    after.append(char)
                } else if char == separator {
                    found = true
                } else {
                    before.append(char)
                }
            }
            //LogManager.shared.log(self, "getPart is not supported")
            return isFirst ? before : after
        }
    }
    
    func split(_ separator: Character) -> [String] {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        var result = [String]()

        if #available(iOS 16.0, *) {
            let splited = trimmed.split(separator: separator)
            for splitedUnit in splited {
                result.append(String(splitedUnit))
            }
        } else {
            var splitedUnit = String()

            var lastInserted = false
            for char in trimmed {
                if char == separator {
                    result.append(splitedUnit)
                    splitedUnit = String()
                    lastInserted = true
                } else {
                    splitedUnit.append(char)
                    lastInserted = false
                }
            }
            if !lastInserted {
                result.append(splitedUnit)
            }
        }
        return result
    }
    
    func getPart(_ separator: Character, index: Int) -> String? {
        let split = split(separator)
        return split.count > index ? split[index] : nil
    }
    
    func extractLoggerName() -> String {
        var tmp = self.getPart(":")
        tmp = tmp.getPart(".", isFirst: false)
        tmp = tmp.getPart("(")
        tmp = tmp.getPart(")")
        return tmp
    }
    
    func toFloat() -> Float {
        (self as NSString).floatValue
    }
    
    func toInt() -> Int {
        (self as NSString).integerValue
    }
}
