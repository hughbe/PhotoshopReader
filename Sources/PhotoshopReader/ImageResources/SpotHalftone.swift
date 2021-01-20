//
//  SpotHalftone.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x0413 1043 (Photoshop 5.0) Spot Halftone. 4 bytes for version, 4 bytes for length, and the variable length data.
public struct SpotHalftone {
    public let version: UInt32
    public let data: [UInt8]
    public let unused: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 8 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)

        let length: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        self.data = try dataStream.readBytes(count: Int(length))
        
        self.unused = try dataStream.readBytes(count: dataStream.remainingCount)
    }
}
