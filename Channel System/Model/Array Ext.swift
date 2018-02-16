//
//  Array Ext.swift
//  Channel System
//
//  Created by Warren Hansen on 2/16/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

extension Collection {
    
    func chunked(by distance: IndexDistance) -> [[Element]] {
        precondition(distance > 0, "distance must be greater than 0") // prevents infinite loop
        
        var index = startIndex
        let iterator: AnyIterator<Array<Element>> = AnyIterator({
            let newIndex = self.index(index, offsetBy: distance, limitedBy: self.endIndex) ?? self.endIndex
            defer { index = newIndex }
            let range = index ..< newIndex
            return index != self.endIndex ? Array(self[range]) : nil
        })
        
        return Array(iterator)
    }
    
}
