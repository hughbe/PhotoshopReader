//
//  PrintScale.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

public struct PrintScale {
    public let style: Style
    public let xLocation: Float
    public let yLocation: Float
    public let scale: Float
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 14 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 bytes style (0 = centered, 1 = size to fit, 2 = user defined).
        self.style = try Style(dataStream: &dataStream)
        
        /// 4 bytes x location (floating point).
        self.xLocation = try dataStream.readFloat(endianess: .bigEndian)
        
        /// 4 bytes y location (floating point).
        self.yLocation = try dataStream.readFloat(endianess: .bigEndian)
        
        /// 4 bytes scale (floating point)
        self.scale = try dataStream.readFloat(endianess: .bigEndian)
    }
    
    public enum Style: UInt16, DataStreamCreatable {
        case centered = 0
        case sizeToFit = 1
        case userDefined = 2
    }
}
