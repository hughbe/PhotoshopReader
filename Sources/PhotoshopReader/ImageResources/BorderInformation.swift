//
//  BorderInformation.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x03F1 1009 Border information. Contains a fixed number (2 bytes real, 2 bytes fraction) for the border width, and 2 bytes for border
/// units (1 = inches, 2 = cm, 3 = points, 4 = picas, 5 = columns).
public struct BorderInformation {
    public let width: UInt32
    public let units: DimensionUnit
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 6 else {
            throw PhotoshopReadError.corrupted
        }

        self.width = try dataStream.read(endianess: .bigEndian)
        self.units = try DimensionUnit(dataStream: &dataStream)
    }
}
