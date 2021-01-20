//
//  PixelAspectRatio.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x0428 1064 (Photoshop CS) Pixel Aspect Ratio. 4 bytes (version = 1 or 2), 8 bytes double, x / y of a pixel. Version 2, attempting to correct
/// values for NTSC and PAL, previously off by a factor of approx. 5%.
public struct PixelAspectRatio {
    public let version: UInt32
    public let value: Double
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version == 1 || version == 2 else {
            throw PhotoshopReadError.corrupted
        }

        self.version = version
        
        self.value = try dataStream.readDouble(endianess: .bigEndian)
    }
}
