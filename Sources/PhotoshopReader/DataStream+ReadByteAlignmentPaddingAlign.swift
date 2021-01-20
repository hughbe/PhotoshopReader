//
//  DataStream.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

internal extension DataStream {
    mutating func readTwoByteAlignmentPadding(startPosition: Int) throws {
        try readByteAlignmentPadding(startPosition: startPosition, to: 2)
    }
    
    mutating func readFourByteAlignmentPadding(startPosition: Int) throws {
        try readByteAlignmentPadding(startPosition: startPosition, to: 4)
    }

    mutating func readByteAlignmentPadding(startPosition: Int, to: Int) throws {
        let excessBytes = (position - startPosition) % to
        if excessBytes > 0 {
            let padding = to - excessBytes
            guard position + padding <= count else {
                throw PhotoshopReadError.corrupted
            }
            
            position += padding
        }
    }
}
