//
//  BrightnessAndContrast.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Brightness and Contrast
/// Key is 'brit' . Data is as follows:
public struct BrightnessAndContrast {
    public let brightness: UInt16
    public let contrast: UInt16
    public let mean: UInt16
    public let labColorOnly: UInt8
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 7 else {
            throw PhotoshopReadError.corrupted
        }

        /// 2 Brightness
        self.brightness = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Contrast
        self.contrast = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Mean value for brightness and contrast
        self.mean = try dataStream.read(endianess: .bigEndian)
        
        /// 1 Lab color only
        self.labColorOnly = try dataStream.read()
    }
}
