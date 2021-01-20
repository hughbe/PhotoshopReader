//
//  FilterMask.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Filter Mask (Photoshop CS3)
/// Key is 'FMsk' . Data is as follows:
public struct FilterMask {
    public let color: Color
    public let opacity: UInt16
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 10 Color space
        self.color = try Color(dataStream: &dataStream)
        
        /// 2 Opacity
        self.opacity = try dataStream.read(endianess: .bigEndian)
    }
}
